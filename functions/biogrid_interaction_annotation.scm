
(define (biogrid_interaction_annotation)
    	(define gen_int '())
	(define prot_int '())
	(define remain '())
    	(set! result (list (ConceptNode "biogrid_interaction_annotation")))
    
    (for-each (lambda (gene)
	(set! gen_int (cog-outgoing-set (findGeneInteractor gene)))

	(if (equal? interaction "proteins")
	     (set! result (append result (cog-outgoing-set (findProtInteractor gene)))))

	(if (equal? interaction "genes") 
           (begin
	        (set! remain gen_int)
	        (for-each (lambda (g)
                    (set! result (append result 
                    (list (EvaluationLink (PredicateNode "interacts_with") (ListLink gene g)))))

                    ;; check for output genes if interacting to each other
	            (set! remain (cdr remain))
		    (for-each (lambda (r)
    			(if (member g (cog-outgoing-set (findGeneInteractor r)))
    				(set! result (append result 
				(list (EvaluationLink (PredicateNode "interacts_with") (ListLink g r))))))
   		    ) remain)
		)gen_int)))

    )gene_nodes)

  result
)
