module Main where
    import System.Environment ( getArgs )
    import Control.Monad.Reader

    import Grammar.Par
    import Grammar.Abs
    import Grammar.ErrM
    import TypeChecker
    import EvalAndExec
    import Exceptions

    run :: String -> IO ()
    run program = do
        let parser = pProgram . myLexer
        case parser program of
            Bad e -> error e
            Ok (Program p) -> do
                check <- runProgramCheck p
                case check of
                    (Left err) -> printTypeCheckError err
                    (Right _) -> do 
                        runResult <- runProgram p
                        case runResult of
                            Left err -> printRuntimeError err
                            Right _ -> return ()
            _ -> undefined
            

    main :: IO ()
    main = do
        file <- getArgs
        case file of
            [] -> liftIO getContents >>= run
            f:_ -> do
                program <- readFile f
                run program