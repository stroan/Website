---
title: Haskell libexpect bindings
layout: project

project_name: hsexpect
project_image: /images/haskell-project.png
project_tag: Tech
project_summary: Haskell bindings to the C expect libraries for interacting with pseudoterminals.
---

This is my haskell bindings to the C expect library. The expect library provides a way to interact with command line applications. It launches the applications inside pseudoterminals. This is nessecary to interact with programs like "passwd", which behave different if their processes stdin or stdout aren't directed at a terminal, which would be the case if the program were launched directly as a child process and the stdin/stdout handles grabbed for reading and writing.

Prerequisites
-------------

* Current versions of GHC and Cabal.
* libexpect. I have found there to be problems with the debian expect-dev package in the squeeze. The expect-tcl8.3-dev package does work though. If both packages are installed the installer will take the 8.3 in preference to newer versions.

Installing
----------

In order to install the package:

    cabal install libexpect

This should download libexpect, and install it, along with any tools or packages required.

Usage
-----

The following is an example of using the current version of the library to interact with the "adduser" command.

{% highlight haskell %}
import System.Expect
import Control.Monad(replicateM_)

main = do
  muteExpect
  proc  <- spawnExpect "adduser test7"
  case1 <- expectCases proc [ ExpectCase "exists." ExpExact 1
                            , ExpectCase "password:" ExpExact 2]
  case case1 of
    Nothing -> putStrLn "Unknown behavior."
    Just 1 -> putStrLn "User exists."
    _ -> do sendLine proc "testpass"
            expectExact proc "password:"
            sendLine proc "testpass"
            replicateM_ 5 $ do expectExact proc "[]:"
                               sendLine proc ""
            expectExact proc "[Y/n]"
            sendLine proc "Y"
            putStrLn "User created"
{% endhighlight %}


The first line, the muteExpect is required to stop the child process's output being echoed to stdout. The main means of interaction with the expect process is the expectCases function, which takes a list of ExpectCases, and returns Just the Value field of the case that matched the way the program behaved, or Nothing if no case matched before EOF or timeout. The ExpectType field of the ExpectCase structure tells the expect library how to deal with the pattern provided. ExpExact, as was used here, is just matched against exactly. ExpRegex treats the pattern as a regex.

The sendLine action sends a line of input to the process, appending the newline character.

Combinator Library
------------------

There is a small monadic combinator library which provides a simple DSL for defining the expect interactions. This is contained in the module System.Expect.ExpectCombinators

Again to show the adduser example, built up again using the DSL.

{% highlight haskell %}
import Control.Monad(replicateM_)
import System.Expect
import System.Expect.ExpectCombinators

main = adduser "test" "pass"

adduser user pass = runExpectIO $ do
  spawn ("adduser " ++ user)
  switch [ exists, passwordRequested ] unknown
  where
     exists = check ExpExact "exists" $ do
              return $ putStrLn "User exists."
     passwordRequested = check ExpExact "password:" $ do
                         send pass
                         wait ExpExact "password:"
                         send pass
                         replicateM_ 5 $ do wait ExpExact "[]:"
                                            send ""
                         wait ExpExact "[Y/n]"
                         send "Y"
                         return $ putStrLn "User created."
     unknown = putStrLn "Undefined behavior."
{% endhighlight %}

The functionality is pretty minimal. Inside the ExpectM monad the following operations are defined:

* `spawn` creates the child process.
* `wait` waits for a pattern to match (or times out).
* `send` sends a line of input.
* `switch` takes a list of options and performs the ExpectM action.
* `check` builds an option for use in 'switch' by taking a pattern and an associated action.

Using these, the description of the expect interaction is defined. To run the ExpectM action, and retrieve the result, the action is passed to 'runExpectIO'. runExpect takes an action, performs it and returns the resultant value. runExpectIO is specific to the case where the ExpectM action is infact returning an IO action. It joins the result of runExpect, which is IO ( IO a ) in the case of an action of type ExpectM (IO a).

Links
-----

* [Hackage package](http://hackage.haskell.org/package/libexpect)
* [Docs](http://hackage.haskell.org/packages/archive/libexpect/0.3.0/doc/html/System-Expect.html)
* [Github](https://github.com/stroan/haskell-libexpect). The preferred way to submit changes is through github pull request, or just email me patches,
  whatever works.