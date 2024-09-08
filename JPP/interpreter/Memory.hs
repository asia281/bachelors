module Memory where
    import Grammar.Abs

    import Data.Map as Map
    import Data.Bifunctor
    import Control.Monad.Reader
    import Control.Monad.State
    import Control.Monad.Except

    import Types
    -- we have mappings env: ident -> loc and store: loc -> vmem

    addIdentToMem :: Ident -> VMemory -> Interpreter Env
    addIdentToMem (Ident ident) vmem = do
        env <- ask
        (store, loc) <- get 
        -- add updated store and location (= loc + 1)
        let new_store = Map.insert loc vmem store
        put (new_store, loc + 1)
        -- and return updated env
        let new_env = Map.insert ident loc env
        return new_env

    getFunLoc :: Interpreter Loc
    getFunLoc = do        
        (_, loc) <- get
        modify (second (+1))
        return loc
                    

    updateIdentInMem :: Ident -> VMemory -> Interpreter ()
    updateIdentInMem (Ident ident) vmem = do
        env <- ask
        (store, loc) <- get 
        -- get location from env
        case Map.lookup ident env of
            Just ident_location -> do
                let new_store = Map.insert ident_location vmem store
                -- and change the V in store
                put (new_store, loc)
                return ()
            _ -> throwError VarDoesntExist


    getLocFromIdent :: Ident -> Interpreter Loc
    getLocFromIdent (Ident ident) = do
        env <- ask
        case Map.lookup ident env of
            Just ident_location -> return ident_location
            _ -> throwError VarDoesntExist

    getValueFromIdent :: Ident -> Interpreter VMemory
    getValueFromIdent ident = do
        (store, _) <- get
        ident_loc <- getLocFromIdent ident
        case Map.lookup ident_loc store of
            Just vmem -> return vmem
            _ -> throwError VarDoesntExist