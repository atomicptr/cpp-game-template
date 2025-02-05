#!/usr/bin/env bb

(require '[babashka.pods :as pods])

(pods/load-pod 'org.babashka/fswatcher "0.0.5")

(require '[babashka.process :refer [shell]]
         '[pod.babashka.fswatcher :as fw])

(def target-dir "build/web")

(defn on-change [event]
  (println "Watcher Event: " event)
  (try
    (println "### Rebuilding web")
    (shell "just" "__web_build")
    (catch Exception e
      (println "ERR: When rebuilding web " (.getMessage e)))))

(fw/watch "src/game" on-change {:delay-ms 100 :recursive true})

(try
  (shell "just" "__web_build")
  (shell "http-server" target-dir)
  (catch Exception e
    (println "ERR: Could not build project. " (.getMessage e)))
  (System/exit 1))
