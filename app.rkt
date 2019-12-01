#lang racket
(require web-server/servlet)
(require web-server/servlet-env)
(require db/mongodb)
(require db/mongodb/basic/main)
(require json)

(define m (create-mongo))
(define d (mongo-db m "psoogle"))
(define resources (mongo-collection d "resources"))

(define seed-data
  (lambda ()
    (mongo-db-drop-collection! d "resources")
    (define resources (mongo-collection d "resources"))

    (define first-resource
      `((title . "Hacker News")
        (url . "https://news.ycombinator.com")))

    (mongo-collection-insert-one! resources first-resource)

    (define second-resource
      `((title . "Twitter")
        (url . "https://twitter.com")))

    (mongo-collection-insert-one! resources second-resource)

    (define third-resource
      `((title . "Lobsters")
        (url . "https://lobste.rs")))

    (mongo-collection-insert-one! resources third-resource)
    
    (define fourth-resource
      `((title . "Product Hunt")
        (url . "https://producthunt.com")))
    
    (mongo-collection-insert-one! resources fourth-resource)))

(if (getenv "ENVIRONMENT")
  (display "ENVIRONMENT set, assuming production\n")
  (seed-data))

(define (http-response content)
  (response/full
    200
    #"OK"
    (current-seconds)
    TEXT/HTML-MIME-TYPE
    '()
    (list
      (string->bytes/utf-8 content))))

(define (json-response content)
  (response/full
    200
    #"OK"
    (current-seconds)
    APPLICATION/JSON-MIME-TYPE
    '()
    (list
      (jsexpr->bytes content))))

(define get-all-resources
  (lambda ()
    (for/list ([resource (mongo-collection-find resources `())])
      (hash
        'title (hash-ref resource 'title)
        'url   (hash-ref resource 'url)))))

(define search-with-search-query
  (lambda (search-query)
    (filter
      (lambda (resource)
        (or (string-contains?
              (string-downcase (hash-ref resource 'title))
              (string-downcase search-query))
            (string-contains?
              (string-downcase (hash-ref resource 'url))
              (string-downcase search-query))))
      (get-all-resources))))

(define length
  (lambda (input)
    (cond
      ((empty? input) 0)
      ((cons? input) (+ 1 (length (rest input)))))))

(define (first-n number lst)
  (if (empty? lst)
    '()
    (if (equal? 0 number)
      '()
      (cons (car lst)
            (first-n (- number 1) (cdr lst))))))

(define max-results 3)

(define search
  (lambda (search-query)
    (if
      (string=? search-query "")
        (json-response (first-n max-results (search-with-search-query "")))
        (json-response (first-n max-results (search-with-search-query search-query))))))

(define (blank-search-handler request)
  (search ""))

(define (search-handler request search-query)
  (search search-query))

(define-values (dispatch generate-url)
  (dispatch-rules
    [("search") blank-search-handler]
    [("search" (string-arg)) search-handler]
    [else (error "There is no procedure to handle the url.")]))

(define (request-handler request)
  (dispatch request))

(define port (if (getenv "PORT")
                 (string->number (getenv "PORT"))
                 8000))

(serve/servlet
  request-handler
  #:launch-browser? #f
  #:servlet-path ""
  #:quit? #f
  #:listen-ip "127.0.0.1"
  #:port port
  #:servlet-regexp #rx"search"
  #:extra-files-paths (list (build-path (current-directory) "web" "public")))