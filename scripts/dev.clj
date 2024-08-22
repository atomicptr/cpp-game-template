#!/usr/bin/env bb

(require '[babashka.pods :as pods])

(pods/load-pod 'org.babashka/fswatcher "0.0.5")

(require '[babashka.fs :as fs]
         '[babashka.process :refer [shell]]
         '[pod.babashka.fswatcher :as fw])

; Deleting old files
(doseq [file (concat
              (fs/glob "bin/target/dev" "**.so")
              (fs/glob "bin/target/dev" "**.tmp"))]
  (fs/delete file))

(defn on-change [event]
  (println "Watcher Event: " event)
  (try
    (println "### Rebuilding dynlib")
    (shell "make" "__dev_dl")
    (catch Exception e
      (println "ERR: When rebuilding the dynamic lib. " (.getMessage e)))))

(fw/watch "src/game" on-change {:delay-ms 100 :recursive true})

(try
  (shell "make" "__dev_dl")
  (shell "make" "__dev_game")
  (catch Exception e
    (println "ERR: Could not build project. " (.getMessage e)))
  (System/exit 1))
