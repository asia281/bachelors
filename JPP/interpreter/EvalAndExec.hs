module EvalAndExec(runProgram) where
    import Grammar.Abs

    import qualified Data.Map.Strict as Map
    import Data.List as List

    import Control.Monad.Reader
    import Control.Monad.State
    import Control.Monad.Except

    import Types
    import Memory

-- EXPRESSION --
    evalAddOp :: AddOp -> Integer -> Integer -> Integer
    evalAddOp Minus e1 e2 = e1 - e2
    evalAddOp Plus e1 e2 = e1 + e2

    evalMulOp :: MulOp -> Integer -> Integer -> Integer
    evalMulOp Mul e1 e2 = e1 * e2
    evalMulOp Div e1 e2 = div e1 e2
    evalMulOp Mod e1 e2 = e1 `mod` e2

    evalRelOp :: RelOp -> Integer -> Integer -> Bool
    evalRelOp LTH e1 e2 = e1 < e2
    evalRelOp LE e1 e2 = e1 <= e2
    evalRelOp GTH e1 e2 = e1 > e2
    evalRelOp GE e1 e2 = e1 >= e2
    evalRelOp Grammar.Abs.EQ e1 e2 = e1 == e2
    evalRelOp NEQ e1 e2 = e1 /= e2

    evalExpr :: Expr -> Interpreter VMemory
    evalExpr (EVar ident) = getValueFromIdent ident
    evalExpr ETrue = return $ VBool True
    evalExpr EFalse = return $ VBool False
    evalExpr (EInt var) = return $ VInt var
    evalExpr (EString str) = return $ VString str
    evalExpr (EEmptyList typ) = return $ VList (typ, [])

-- bool operators
    evalExpr (ERel e1 op e2) = do
        VInt done1 <- evalExpr e1 
        VInt done2 <- evalExpr e2
        return $ VBool $ evalRelOp op done1 done2

    evalExpr (EAnd e1 e2) = do
        VBool done1 <- evalExpr e1 
        VBool done2 <- evalExpr e2
        return $ VBool $ done1 && done2

    evalExpr (EOr e1 e2) = do
        VBool done1 <- evalExpr e1 
        VBool done2 <- evalExpr e2
        return $ VBool $ done1 || done2

    evalExpr (ENot e) = do
        VBool done <- evalExpr e
        return $ VBool $ not done
    
--  int operators
    evalExpr (EAdd e1 op e2) = do
        VInt done1 <- evalExpr e1 
        VInt done2 <- evalExpr e2
        return $ VInt $ evalAddOp op done1 done2

    evalExpr (ENeg e) = do
        VInt done <- evalExpr e 
        return $ VInt $ -done

    evalExpr (EMul e1 op e2) = do
        VInt done1 <- evalExpr e1 
        VInt done2 <- evalExpr e2
        if done2 == 0 && (op == Div || op == Mod) then 
            throwError ZeroDivisionException 
        else 
            return $ VInt $ evalMulOp op done1 done2

-- lists
    evalExpr (EListLen l) = do
        VList (_, elements) <- evalExpr l
        return $ VInt $ fromIntegral $ length elements

    evalExpr (EListAt l pos) = do
        VInt idx <- evalExpr pos
        VList (_, elements) <- evalExpr l
        let listLen = fromIntegral (length elements)
        if idx < 0 || listLen <= idx then
            throwError $ OutOfRangeExeption listLen idx
        else 
            return $ elements !! fromIntegral idx

--lambda
    evalExpr (ELambda args typ (Block block)) = do 
        env <- ask
        fun <- makeFun args block typ env
        return $ VFun fun

    evalExpr (EApp ident vars) = do
        VFun fun <- evalExpr ident
        values <- mapM evalVarForFun vars
        fun values

    evalVarForFun :: ExprOrRef -> Interpreter FuncVal
    evalVarForFun (EorRRef ident) = do
        loc <- getLocFromIdent ident
        return $ ByReference loc

    evalVarForFun (EorRExpr expr) = do
        val <- evalExpr expr
        return $ ByType val
    
-- Declarations
    defaultValue :: Type -> Expr
    defaultValue TInt = EInt 0
    defaultValue TBool = EFalse
    defaultValue TString = EString ""
    defaultValue (TList t) = EEmptyList t
    defaultValue TVoid = undefined
    defaultValue (TLambda _ _) = undefined


    initalised :: Type -> Ident -> Expr -> Interpreter (Env, ReturnRes)
    initalised _ ident expr = do
        evaledExpr <- evalExpr expr
        new_env <- addIdentToMem ident evaledExpr
        return (new_env, Nothing)

    argsToFunArgs :: Env -> (Arg, FuncVal) -> Interpreter Env
    argsToFunArgs prevEnv ((Arg _ i), (ByType val)) = do
        local (const prevEnv) (addIdentToMem i val)

    argsToFunArgs prevEnv ((Arg _ (Ident i)), (ByReference loc)) = do
        -- sprawdz czy nie pomylilam i z ident
        return (Map.insert i loc prevEnv)

    makeFun :: [Arg] -> [Stmt] -> Type -> Env -> Interpreter FuncDef
    makeFun args block typ env = do
        let fun vals = do
                fun_env <- foldM argsToFunArgs env (zip args vals)
                (_, retRes)<- local (const fun_env) (execList block)
                case (retRes, typ) of
                    (Nothing, TVoid) -> return VVoid
                    -- typechecker powinien sprawdzic (_, VVoid)
                    (Just vRetRes, _) -> return vRetRes
                    _ -> throwError $ NoReturnException
        return fun

    execStmt :: Stmt -> Interpreter (Env, ReturnRes)
    execStmt (Decl typ i) = do
        case i of
            NoInit ident -> initalised typ ident (defaultValue typ)
            Init ident expr -> initalised typ ident expr

    execStmt (FunDef (Ident ident) args typ (Block block)) = do 
        funLoc <- getFunLoc         
        env <- ask       
        fun_env <- return $ Map.insert ident funLoc env
        fun <- makeFun args block typ fun_env
        (store, loc) <- get 
        let new_store = Map.insert funLoc (VFun fun) store
        put (new_store, loc)
        return (fun_env, Nothing)


    execStmt (SListPush ident expr) = do
        evaledExpr <- evalExpr expr
        VList (typ, list) <- getValueFromIdent ident
        let newList = VList (typ, list ++ [evaledExpr])
        updateIdentInMem ident newList
        returnNothing

-- assignment
    execStmt (Assign ident expr) = do
        evaledExpr <- evalExpr expr
        updateIdentInMem ident evaledExpr
        returnNothing

    execStmt (SExpr expr) = do
        _ <- evalExpr expr
        returnNothing

-- return
    execStmt ReturnVoid = do
        env <- ask
        return (env, Just VVoid)

    execStmt (Return expr) = do
        env <- ask
        val <- evalExpr expr
        return (env, Just val)
    
-- conditions
    execStmt (If cond (Block block)) = do
        VBool evaledCond <- evalExpr cond
        if evaledCond then
            execList block
        else 
            returnNothing  
            
    execStmt (IfElse cond (Block block1) (Block block2)) = do
        VBool evaledCond <- evalExpr cond
        if evaledCond then
            execList block1
        else 
            execList block2  
-- loops
    execStmt (While cond (Block block)) = do
        VBool evaledCond <- evalExpr cond
        if evaledCond then do
            (_, returned) <- execList block
            case returned of
                Nothing -> execStmt (While cond (Block block))
                _ -> returnNothing
        else 
            returnNothing


    execStmt (For ident start end (Block block)) = do
        VInt evaledStart <- evalExpr start
        VInt evaledEnd <- evalExpr end
        updateIdentInMem ident (VInt evaledStart)
        let plusOne = [Assign ident (EAdd (EInt 1) Plus (EVar ident))]
        let forBlock = Block (block ++ plusOne)
        let cond = ERel (EVar ident) LE (EInt evaledEnd)
        execStmt $ While cond forBlock

-- print
    execStmt (Print e) = 
        case e of
            [] -> returnNothing
            h:t -> do
                expr <- evalExpr h
                if t == [] then do
                    liftIO $ putStr (vToString expr)
                else do
                    liftIO $ putStr (vToString expr ++ " ")
                
                execStmt (Print t)
        
    execStmt (PrintEndl e) = execStmt (Print (e ++ [EString "\n"])) 
        
    vToString :: VMemory -> String
    vToString (VInt x) = show x
    vToString (VBool x) = show x
    vToString (VString s) = s
    vToString (VList (typ, elements)) = "Type of list: " ++ show typ ++ ", [" ++ (foldl' (\a b -> a ++ (vToString b) ++ ", " ) "" elements) ++ "]"
    vToString _ = undefined

    returnNothing :: Interpreter (Env, ReturnRes)
    returnNothing = do
        env <- ask
        return (env, Nothing)


    execList :: [Stmt] -> Interpreter (Env, ReturnRes)
    execList [] = returnNothing
    execList (h:t) = do
        (env, ret) <- execStmt h
        case ret of
            Nothing -> local (const env) (execList t)
            _ -> return (env, ret)

    

    runProgram :: [Stmt] -> IO (Either RuntimeExceptions ((Env, ReturnRes), Store))
    runProgram program = runExceptT $ runStateT (runReaderT (execList program) Map.empty) (Map.empty, 0)