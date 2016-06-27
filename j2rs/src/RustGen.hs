{-# LANGUAGE RecordWildCards #-}
module RustGen where

import Data.Maybe
import Data.List
import AST
import Control.Monad.Writer

genRust :: [Class] -> String
genRust classes = execWriter $ do
    tell $ "extern crate jni_sys; use jni_sys::*;\n"

    let member Member{..} =
          case memberGuts of
            MethodM javaName params | not (isStatic memberModifiers) ->
                Just (memberGuts, fromMaybe javaName memberAs, javaName, memberType, params)
            ConstructorM params ->
                Just (memberGuts, fromMaybe "new" memberAs, "<init>", ["void"], params)
            _ -> Nothing

    forM_ classes $ \Class{..} -> do
        let structName = qnameRs className

        let members = mapMaybe member classMembers

        tell $ "static mut class_" ++ structName ++ ": jclass = 0 as jclass;\n"

        forM_ members $ \(guts, rustName, javaName, type_, params) -> do
            tell $ "static mut method_" ++ structName ++ "_" ++ rustName ++
                " : jmethodID = 0 as jmethodID;\n"

        tell $ "pub struct " ++ structName ++ "(*mut JNIEnv, jobject);\n"
        tell $ "impl " ++ structName ++ " {\n"
        
        tell $ "\tpub unsafe fn wrap(env: *mut JNIEnv, obj: jobject) -> " ++ structName ++ " {\n"
        tell $ "\t\t" ++ structName ++ "(env, obj)\n"
        tell $ "\t}\n"

        tell $ "\tpub fn jobject(&self) -> jobject { self.1 }\n"

        forM_ members $ \(guts, name, javaName, memberType, params) -> do
            let paramVals = concatMap
                 (\(index, type_) -> ", " ++ unwrap type_ ("p" ++ show index))
                 (zip [0..] params)

            case guts of

              MethodM{} -> do
                tell $ "\tpub fn " ++ name ++ "(&self" ++ concatMap ((", "++) . paramRs) (zip [0..] params) ++ ") -> " ++ retTypeRs memberType ++ " {\n"
                let callExpr = "((**self.0)." ++ envCallFuncName memberType ++ ")(self.0, self.1, method_" ++
                        structName ++ "_" ++ name ++ paramVals ++ ")"
                tell $ "\t\tunsafe { " ++ wrap "self.0" memberType callExpr ++ " }\n"
                tell $ "\t}\n"

              ConstructorM{} -> do
                tell $ "\tpub fn " ++ name ++ "(env: *mut JNIEnv" ++ concatMap ((", "++) . paramRs) (zip [0..] params) ++ ") -> " ++ retTypeRs className ++ " {\n"
                let callExpr = "((**env).NewObject)(env, class_" ++ structName ++ ", method_" ++
                        structName ++ "_" ++ name ++ paramVals ++ ")"
                tell $ "\t\tunsafe { " ++ wrap "env" className callExpr ++ " }\n"
                tell $ "\t}\n"
                

        tell "}\n"

    
    tell $ "pub unsafe fn native_init(env: *mut JNIEnv) {\n"
    forM_ classes $ \Class{..} -> do
        let structName = qnameRs className

        tell $ "\tclass_" ++ structName ++ " = ((**env).NewGlobalRef)(env, ((**env).FindClass)(env, " ++
            "\"" ++ javaClassSig className ++ "\\0\".as_ptr() as *const i8));\n"

        forM_ (mapMaybe member classMembers) $ \(guts, name, javaName, memberType, params) -> do
            let varName = "method_" ++ structName ++ "_" ++ name
                javaSig = javaMethodSig params memberType
            tell $ "\t" ++ varName ++ " = ((**env).GetMethodID)(env, " ++
                "class_" ++ structName ++ ", \"" ++ javaName ++ "\\0\".as_ptr() as *const i8, \"" ++
                javaSig ++ "\\0\".as_ptr() as *const i8);\n"
    tell $ "}\n"

javaMethodSig params ret = "(" ++ concatMap javaTypeSig params ++ ")" ++ javaTypeSig ret

javaTypeSig ["int"] = "I"
javaTypeSig ["long"] = "L"
javaTypeSig ["void"] = "V"
javaTypeSig ["boolean"] = "Z"
javaTypeSig t = "L" ++ javaClassSig t ++ ";"

javaClassSig t = intercalate "/" t

envCallFuncName ["int"] = "CallIntMethod"
envCallFuncName ["long"] = "CallLongMethod"
envCallFuncName ["void"] = "CallVoidMethod"
envCallFuncName ["boolean"] = "CallBooleanMethod"
envCallFuncName t = "CallObjectMethod"

unwrap type_ expr
    | isPrimitive type_ = expr
    | otherwise = -- object wrapper
        expr ++ ".1"

wrap env type_ expr
    | isPrimitive type_ = expr
    | otherwise = -- object wrapper
        qnameRs type_ ++ "(" ++ env ++ ", " ++ expr ++ ")"

isPrimitive ["int"] = True
isPrimitive ["long"] = True
isPrimitive ["boolean"] = True
isPrimitive ["void"] = True
isPrimitive t = False

qnameRs :: QualifiedName -> String
qnameRs = intercalate "_"

retTypeRs ["void"] = "()"
retTypeRs t
    | isPrimitive t = typeRs t
    | otherwise = qnameRs t

typeRs ["long"] = "jlong"
typeRs ["int"] = "jint"
typeRs t = "&" ++ qnameRs t

paramRs (index, type_) = "p" ++ show index ++ ": " ++ typeRs type_
