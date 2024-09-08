module DensePoly() where
import PolyClass
import Representation
import Data.List

instance Functor DensePoly where
    fmap f (P pl) = P (f <$> pl)

instance Polynomial DensePoly where
    zeroP  = P []
    constP a 
        | a == 0 = zeroP
        | otherwise = P [a]
    varP = P [0, 1]
    evalP (P pl) x = evalPAcc x (reverse pl) 0
        where evalPAcc x pl acc = case pl of
                [] -> acc
                pHead : pTail -> evalPAcc x pTail (acc * x + pHead)
    shiftP n (P pl) 
        | pl == [] || n == 0 = P (simplify pl)
        | (n < 0) = P (simplify (drop (-n) pl))
        | otherwise = shiftP (n-1) (P (0 : pl))

    degree (P pl) = length pl - 1

simplify :: (Eq a, Num a) => [a] -> [a]
simplify = dropWhileEnd (0 ==)

add ::  (Eq a, Num a) => [a] -> [a] -> [a]
add [] b = b
add a b | (length a) > (length b) = add b a
add (ah : at) (bh : bt) = (ah + bh) : (add at bt) 

mulConst ::  (Eq a, Num a) => a -> [a] -> [a]
mulConst a b  =  (* a) <$> b

mul :: (Eq a, Num a) => [a] -> [a] -> [a]
mul a b =
    case (a, b) of
        ([], _) -> []
        ((ah : at), b) -> add (mulConst ah b) l
            where P l = (shiftP 1 (P (mul at b)))   

instance (Eq a, Num a) => Num (DensePoly a) where
    (P al) + (P bl) = P (simplify (add al bl))
    (P al) * (P bl) = P (simplify (mul al bl))
    negate (P al) = (constP (-1)) * (P al)
    abs = undefined
    signum = undefined
    fromInteger = constP . fromInteger


-- |
-- >>> let x = varP :: DensePoly Integer in x^3 - 1
-- P {unP = [-1,0,0,1]}
instance (Eq a, Num a) => Eq (DensePoly a) where
   P list1 == P list2 = (simplify list1 == simplify list2) 


-- |
-- >>>  P [1,2] == P [1,2]
-- True

-- |
-- >>> fromInteger 0 == (zeroP :: DensePoly Int)
-- True

-- |
-- >>>  P [0,1] == P [1,0]
-- False

-- | Degree examples
-- >>> degree (zeroP :: DensePoly Int)
-- -1
-- >>> degree (constP 1 :: DensePoly Int)
-- 0
