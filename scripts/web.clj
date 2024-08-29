#!/usr/bin/env bb

(require '[babashka.pods :as pods])

(pods/load-pod 'org.babashka/fswatcher "0.0.5")

(require '[babashka.process :refer [shell]]
         '[pod.babashka.fswatcher :as fw])

(defn on-change [event]
  (println "Watcher Event: " event)
  (try
    (println "### Rebuilding web")
    (shell "make" "build-web")
    (catch Exception e
      (println "ERR: When rebuilding web " (.getMessage e)))))

(fw/watch "src/game" on-change {:delay-ms 100 :recursive true})

(try
  (shell "make" "build-web")
  (shell "http-server" "bin/debug/web")
  (catch Exception e
    (println "ERR: Could not build project. " (.getMessage e)))
  (System/exit 1))
