#!/usr/bin/env bb

(def executable-name "demo_dev")
(def base-path "build")

(require '[babashka.pods :as pods])

(pods/load-pod 'org.babashka/fswatcher "0.0.5")

(require '[babashka.fs :as fs]
         '[babashka.process :refer [shell]]
         '[pod.babashka.fswatcher :as fw])

; Deleting old files
(doseq [file (concat
              (fs/glob base-path "**.so")
              (fs/glob base-path "**.tmp"))]
  (fs/delete file))

(defn on-change [event]
  (println "Watcher Event: " event)
  (try
    (println "### Rebuilding dynlib")
    (shell "just" "build")
    (catch Exception e
      (println "ERR: When rebuilding the dynamic lib. " (.getMessage e)))))

(fw/watch "src/game" on-change {:delay-ms 100 :recursive true})

(try
  (shell "just" "build")
  (shell (str "./build/" executable-name))
  (catch Exception e
    (println "ERR: Could not build project. " (.getMessage e)))
  (System/exit 1))
