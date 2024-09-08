module SparsePoly(fromDP, toDP, qrP) where
import PolyClass
import Representation
import Data.List

-- | fromDP example
-- >>> fromDP sampleDP
-- S {unS = [(3,1),(0,-1)]}
fromDP :: (Eq a, Num a) => DensePoly a -> SparsePoly a
toDP :: (Eq a, Num a) => SparsePoly a -> DensePoly a


fromDP (P pl) = S (createSP (P pl) 0 [])
    where createSP (P pl) cnt acc = case pl of
            [] -> acc
            pHead : pTail | pHead /= 0 -> createSP (P pTail) (cnt+1) ((cnt, pHead) : acc)
            pHead : pTail -> createSP (P pTail) (cnt+1) acc

appendZeros :: (Eq a, Num a) => Int -> Int -> a -> [a] -> [a]
appendZeros prev curr toAdd acc 
    | prev == curr = acc
    | prev < 0 || prev-1 == curr  = toAdd : acc
    | otherwise = appendZeros (prev-1) curr toAdd (0 : acc)

toDP (S sl) 
    | sl == []  = (P [])
    | otherwise = P (createDP (S sl) (-1) []) 
    where createDP (S sl) prev acc = case sl of
            [] -> (appendZeros prev 0 0 acc)
            (sExp, sNum) : sTail -> createDP (S sTail) sExp (appendZeros prev sExp sNum acc)

first :: (a -> a') -> (a, b) -> (a', b)
first f (a, b)  = (f a, b)
second :: (b -> b') -> (a, b) -> (a, b')
second f (a, b) = (a, f b)

instance Functor SparsePoly where
    fmap f (S sl) = S ((second f) <$> sl)

fastPow :: (Num a) => a -> Int -> a
fastPow base 1 = base
fastPow base pow 
  | even pow = (fastPow base (div pow 2)) ^ 2
  | odd pow = (fastPow base (div (pow-1) 2)) ^ 2 * base

instance Polynomial SparsePoly where
    zeroP  = S []
    constP a 
        | a == 0 = zeroP
        | otherwise = S [(0, a)]
    varP = S [(1, 1)]
    evalP (S sl) n = foldl' (\x (yExp, yCoeff) -> (x + yCoeff * (fastPow n yExp))) 0 sl    

    degree (S sl) = case sl of
        [] -> -1
        (exp, _) : _ -> exp
        
    shiftP n (S sl) = S (map (\y -> (first (\x -> n+x) y)) sl)

simplify :: (Eq a, Num a) => [(Int, a)] -> [(Int, a)]
simplify = filter ((/= 0) . snd)


add ::  (Eq a, Num a) => [(Int, a)] -> [(Int, a)] -> [(Int, a)]
add a b = addAcc a b []
    where addAcc [] [] acc = reverse acc
          addAcc (ah : at) [] acc = addAcc at [] (ah : acc)
          addAcc [] (bh : bt) acc = addAcc bt [] (bh : acc)
          addAcc (ah : at) (bh : bt) acc | (fst ah) == (fst bh) = addAcc at bt (((fst ah), ((snd ah) + (snd bh))) : acc) 
          addAcc (ah : at) (bh : bt) acc | (fst ah) > (fst bh) = addAcc at (bh : bt) (ah : acc)
          addAcc a b acc = addAcc b a acc

mulConst ::  (Eq a, Num a) => (Int, a) -> [(Int, a)] -> [(Int, a)]
mulConst (aExp, aCoeff) = map (\(x, y) -> (x + aExp, y * aCoeff))

mul :: (Eq a, Num a) => [(Int, a)] -> [(Int, a)] -> [(Int, a)]
mul a b = foldl' add [] (foldl' (\acc ah -> (mulConst ah b) : acc) [] a)

instance (Eq a, Num a) => Num (SparsePoly a) where
    (S al) + (S bl) = S (simplify (add al bl))
    (S al) * (S bl) = S (simplify (mul al bl))
    negate (S sl) = (constP (-1)) * (S sl)
    abs = undefined
    signum = undefined
    fromInteger = constP . fromInteger

instance (Eq a, Num a) => Eq (SparsePoly a) where
  p == q = nullP (p - q)

getFirstElem :: (Num a) => SparsePoly a -> a
getFirstElem (S sl) = 
    case sl of
        [] -> 1
        (_, coeff) : _ -> coeff

-- qrP s t | not(nullP t) = (q, r) iff s == q*t + r && degree r < degree t
qrP :: (Eq a, Fractional a) => SparsePoly a -> SparsePoly a -> (SparsePoly a, SparsePoly a)
qrP _ (S []) = undefined
qrP s t = divWithRes s t zeroP
    where divWithRes f s q 
            | ddif < 0 = (q, f)
            | otherwise = divWithRes f' s q'
                where 
                    ddif = (degree f) - (degree s)
                    k = constP ((getFirstElem f) / (getFirstElem s))
                    q' = q + (shiftP ddif k)
                    f' = f - (k * (shiftP ddif s))


-- | Division example
-- >>> let x = varP in qrP (x^2 - 1) (x -1) == ((x + 1), 0)
-- True
