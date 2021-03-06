{-
Copyright © 2017 Albert Krewinkel

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
-}
{-|
Module      :  Foreign.Lua.Types.FromLuaStackTest
Copyright   :  © 2017 Albert Krewinkel
License     :  MIT

Maintainer  :  Albert Krewinkel <tarleb+hslua@zeitkraut.de>
Stability   :  stable
Portability :  portable

Test for the conversion of lua values to haskell values.
-}
module Foreign.Lua.Types.FromLuaStackTest (tests) where

import Foreign.Lua (Lua, LuaInteger, LuaException (LuaException), call,
                    dostring, loadstring, runLua, tryLua)
import Foreign.Lua.Types.FromLuaStack

import Test.Tasty (TestTree, testGroup)
import Test.Tasty.HUnit (assertEqual, testCase)

-- | Specifications for Attributes parsing functions.
tests :: TestTree
tests = testGroup "FromLuaStack"
  [ testCase "receives basic values from the stack" $ do
      assertEqual "true was not read" True =<< runLua
        (loadstring "return true" *> call 0 1 *> peek (-1))
      assertEqual "5 was not read" (5 :: LuaInteger) =<< runLua
        (loadstring "return 5" *> call 0 1 *> peek (-1))

  , testCase "returns an error if the types don't match" $ do
      let boolNum = "Expected a boolean but got a number"
      assertEqual "error messsage mismatched" (Left boolNum) =<< runLua
        (loadstring "return 5" *> call 0 1 *> peekEither (-1) :: Lua (Result Bool))
      let numBoolExcept = LuaException "Expected a number but got a boolean"
      assertEqual "error message mismatched" (Left numBoolExcept) =<< runLua
        (tryLua $ dostring "return true" *> (peek (-1) :: Lua LuaInteger))

  , testCase "list cannot be read if a list element fails" $ do
      let err = "Could not read list: Expected a number but got a boolean"
      assertEqual "error message mismatched" (Left err) =<< runLua
        (loadstring "return {1, 5, 23, true, 42}" *> call 0 1
         *> peekEither (-1) :: Lua (Result [LuaInteger]))
  ]
