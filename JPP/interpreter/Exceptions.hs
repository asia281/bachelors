module Exceptions(printTypeCheckError, printRuntimeError) where
    import Types
    import System.Exit (die)
    printTypeCheckError :: TypeCheckerExceptions -> IO ()
    printTypeCheckError err =
        case err of
            TypeCheckException t1 t2 -> die $ "Mismatch in types, expected: " ++ show t1 ++ ", got: " ++ show t2
            DeclarationInvTypeException t -> die $ "Wrong type of a declared element: " ++ show t
            FuncArgsInvTypeException t -> die $ "Wrong type of argument in function: " ++ show t
            NotListException t -> die $ "Element is not a list: " ++ show t
            NonUniqueArgName fun t -> die $ "In function: " ++ show fun ++ " the following arg name occurs more than once: " ++ show t
            InvalidTypesInApplication -> die $ "Function application got mismatching argument types"
            IncorrectNumberOfArguments t1 t2 -> die $ "Number of required arguments to the function: " ++ show t1 ++ ", got: " ++ show t2
            IdentifierNotExistException str -> die $ "No such identifier: " ++ show str 
            ReturnTypeMismatchException t1 t2 -> die $ "Mismatch in returned types, first: " ++ show t1 ++ ", second: " ++ show t2

    printRuntimeError :: RuntimeExceptions -> IO()
    printRuntimeError err =
        case err of
            NoReturnException -> die $ "Missing return."
            ZeroDivisionException -> die $ "Division by zero."
            PrintNotDefined -> die $ "Print for this type not defined."
            VarDoesntExist -> die $ "Var you're accesing doesn't exist." -- shouldnt be thrown due to TypeChecker
            OutOfRangeExeption li i -> die $ "Out of range. List has length: " ++ show li ++ " and you're accessing element number: " ++ show i
