(define-module (tests main)
	#:use-module (srfi srfi-64)
	#:use-module (ice-9 futures)
	#:use-module (opencog)
	#:use-module (opencog bioscience)
	#:use-module (annotation main)
	#:use-module (annotation functions)
	#:use-module (annotation util)
    #:use-module (annotation gene-go)
    #:use-module (annotation gene-pathway)
    #:use-module (annotation biogrid)
    #:use-module (annotation parser)
	#:use-module (annotation rna)
    #:use-module (json)
)

(test-begin "main")
(setenv "TEST_MODE" "TRUE")
;; Load test atomspace
(primitive-load-path "tests/sample_dataset.scm")
(primitive-load-path "annotation/pln_rule.scm")

(define req "[{\"functionName\": \"gene-pathway-annotation\", \"filters\": [{\"filter\": \"pathway\", \"value\": \"smpdb reactome\"},{\"filter\": \"include_prot\", \"value\": \"True\"}, {\"filter\": \"include_sm\", \"value\": \"False\"},{\"filter\": \"coding\", \"value\": \"True\"},{\"filter\": \"noncoding\", \"value\": \"True\"}, {\"filter\": \"biogrid\", \"value\": \"0\"}]}, {\"functionName\": \"gene-go-annotation\", \"filters\": [{\"filter\": \"namespace\", \"value\": \"biological_process cellular_component molecular_function\"}, {\"filter\": \"parents\", \"value\": \"0\"}, {\"filter\": \"protein\", \"value\": \"True\"}]}, {\"functionName\": \"include-rna\", \"filters\": [{\"filter\": \"coding\", \"value\": \"True\"},{\"filter\": \"noncoding\", \"value\": \"True\"},{\"filter\": \"protein\", \"value\": \"1\"}]},{\"functionName\": \"biogrid-interaction-annotation\", \"filters\": [{\"filter\": \"interaction\", \"value\": \"Proteins\"}]}]")

(define invalid-req "[{\"functionName\": \"unknown-function\", \"filters\": [{\"filter\": \"pathway\", \"value\": \"smpdb reactome\"},{\"filter\": \"include_prot\", \"value\": \"True\"}, {\"filter\": \"include_sm\", \"value\": \"False\"},{\"filter\": \"coding\", \"value\": \"True\"},{\"filter\": \"noncoding\", \"value\": \"True\"}, {\"filter\": \"biogrid\", \"value\": \"0\"}]}]")

(test-equal "parse-request" 4 (length (parse-request req)))

;;This should only return a single list which contains the `gene-info` function. 
;;This is because the function name `unknown-function` is not in the list `annotation-functions`
(test-equal "validate-functions" 1 (length (parse-request invalid-req)))

(test-equal "annotate-genes" #t ((lambda () (annotate-genes (list "IGF1") "Dfaer" req) (file-exists? (get-file-path "Dfaer" "Dfaer" ".json")))))

(test-equal "find-genes" 1 (length (vector->list (json-string->scm (find-genes (list "IGF" "IGF1"))))))

(define namespace (list "biological_process" "molecular_function" "cellular_component"))

(test-equal "protein-goterm" 14 (length (find-proteins-goterm (GeneNode "IGF1") namespace 0 #f #f #f)))


(test-equal "current_vs_prev_symbols" (ListLink) (find-protein-form (GeneNode "NOV")))

(test-equal "find-genes" "[]" (find-genes (list "IGF1" "TF")))

(test-equal "delete-genes" #t (cog-delete-recursive (GeneNode "IGF")))

(clear)
(setenv "TEST_MODE" #f) ;;remove the env variable
(test-end "main")
