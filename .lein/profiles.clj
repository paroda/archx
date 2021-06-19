{:user
 {:dependencies [[org.clojure/clojure "1.10.1"]
                 [nrepl "RELEASE"]
                 ;; [refactor-nrepl "RELEASE" :exclusions [nrepl]]
                 [cider/cider-nrepl "RELEASE" :exclusions [nrepl]]]

  :aliases {"rebel" ["with-profiles" "+rebel"
                     "trampoline" "run" "-m" "rebel-readline.main"]
            }

  :plugins [[lein-localrepo "RELEASE" :exclusions [org.clojure/clojure]]
            [lein-ancient "RELEASE"]
            [clj-http "RELEASE"]
            [lein-pprint "RELEASE"]
            [lein-kibit "RELEASE"]]}

 :repl
 {:middleware [;; refactor-nrepl.plugin/middleware
               cider-nrepl.plugin/middleware]
  :plugins [;; [refactor-nrepl "RELEASE" :exclusions [nrepl]]
            [cider/cider-nrepl "RELEASE" :exclusions [nrepl]]]}

 :rebel
 {:dependencies [[com.bhauman/rebel-readline "RELEASE"
                  :exclusions [org.clojure/clojure]]]}}
