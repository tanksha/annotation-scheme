;;; MOZI-AI Annotation Scheme
;;; Copyright © 2019 Abdulrahman Semrie
;;; Copyright © 2019 Hedra Seid
;;; Copyright © 2019 Enkusellasie Wondesen
;;;
;;; This file is part of MOZI-AI Annotation Scheme
;;;
;;; MOZI-AI Annotation Scheme is free software; you can redistribute
;;; it and/or modify it under the terms of the GNU General Public
;;; License as published by the Free Software Foundation; either
;;; version 3 of the License, or (at your option) any later version.
;;;
;;; This software is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;;; General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with this software.  If not, see
;;; <http://www.gnu.org/licenses/>.

(define-module (annotation util)
	#:use-module (opencog)
  #:use-module (opencog query)
  #:use-module (opencog exec)
  #:use-module (opencog bioscience)
	#:use-module (json)
  #:use-module (ice-9 optargs)
  #:use-module (rnrs base)
  #:use-module (rnrs exceptions)
  #:use-module (ice-9 textual-ports)
  #:use-module (ice-9 regex)
  #:use-module (srfi srfi-1)
  #:use-module (ice-9 match)
  #:export (create-node
            create-edge)
)

;;Define the parameters needed for parsing and GGI
(define-public nodes (make-parameter '()))
(define-public edges (make-parameter '()))
(define-public atoms (make-parameter '()))
(define-public genes (make-parameter '()))
(define-public biogrid-genes (make-parameter '()))
(define-public annotation (make-parameter ""))
(define-public prev-annotation (make-parameter ""))

(define (get-name atom)
 (if (> (length atom) 0)
  (cog-name (car  atom))
  ""
 )
)


(define* (create-node id name defn location annotation #:optional (subgroup ""))
    (make-node (make-node-info id name defn location subgroup annotation) "nodes")
)

(define* (create-edge node1 node2 name annotation #:optional (pubmedId "") (subgroup ""))
   (make-edge (make-edge-info node2 node1 name pubmedId subgroup annotation) "edges")
)

;; Find node name and description

(define-public (node-info node)
    (list
      (EvaluationLink (PredicateNode "has_name") (ListLink node (node-name node)))
      (EvaluationLink (PredicateNode "has_definition") (ListLink node (Concept (build-desc-url node))))
    )
)

(define (node-name node)
	(let
		( [lst (find-pathway-name node)])
			(if (null? lst)
				(ConceptNode "N/A")
				(car lst)
			)
	)
)

;;Finds a name of any node (Except GO which has different structure)
(define find-pathway-name
    (lambda(pw)
			(cog-outgoing-set (cog-execute! (GetLink
				(VariableNode "$a")
				(EvaluationLink
					(PredicateNode "has_name")
					(ListLink
						pw
						(VariableNode "$a")
					)
				)
			)	
		))
	)
)

(define-public (is-cellular-component? node-info)
 (let*
  (
	 [response #f]
  )
  (for-each
   (lambda (info)
    (if (equal? (cog-name (cog-outgoing-atom info 0)) "GO_namespace")
	 (set! response (if (equal? "cellular_component" (cog-name (cog-outgoing-atom (cog-outgoing-atom info 1) 1))) #t #f))
    )
   )
  node-info)
  response
 )
)


(define-public (build-desc-url node)
 (let*
	(
		[atom-type (cog-type node)]
		[description ""]
	)
 	(case atom-type
	 ('MoleculeNode
		(begin
		 (if (equal? (car (string-split (cog-name node) #\:)) "ChEBI")
			(set! description (string-append "https://www.ebi.ac.uk/chebi/searchId.do?chebiId=" (cadr (string-split (cog-name node) #\:))))
	 		(set! description (string-append "https://www.uniprot.org/uniprot/" (cadr (string-split (cog-name node) #\:))))
		 )
		)
	 )
	 ('GeneNode (set! description (string-append "https://www.ncbi.nlm.nih.gov/gene/"  (find-entrez node))))
	 ('ConceptNode
		(begin
		 (if (string-contains (cog-name node) "SMP")
		 	(set! description (string-append "http://smpdb.ca/view/" (cog-name node)))
		 )
		 (if (string-contains (cog-name node) "R-HSA")
		 	(set! description (string-append "http://www.reactome.org/content/detail/" (cog-name node)))
		 )
		)
	 )
	)
	description
 )
)

;; Finds entrez_id of a gene
(define (find-entrez gene)
  (let ((entrez '()))
    (set! entrez (get-name
   (cog-outgoing-set
    (cog-execute!
     (GetLink
       (VariableNode "$a")
       (EvaluationLink
        (PredicateNode "has_entrez_id")
        (ListLink
         gene
         (VariableNode "$a")
        )
       )
    )
   )
  )
  ))
   (if (equal? (length (string-split entrez #\:)) 1)
       entrez
       (cadr  (string-split entrez #\:))
   )
  )
)

;;finds go name for parser function
(define find-name
    (lambda (atom)
     (let*
        (
          [predicate (if (regexp-match? (string-match "GO:[0-9]+" (cog-name atom))) "GO_name" "has_name")]
        )
      (get-name
       (cog-outgoing-set
        (cog-execute!
         (GetLink
          (VariableNode "$name")

          (EvaluationLink
           (PredicateNode predicate)
           (ListLink
            atom
            (VariableNode "$name")
           )
          )
         )
        )
       )
      )
    )
    )
)

(define-public (build-pubmed-url nodename)
 (string-append "https://www.ncbi.nlm.nih.gov/pubmed/?term=" (cadr (string-split nodename #\:)))
)

(define-public (write-to-file result name)
 (let*
	(
		[file-name (string-append "/root/result/scheme/" name ".scm")]
	)
	(call-with-output-file file-name
  	(lambda (p)
		(begin
			(write result p)
		)
	)
	)
 )
)

(define-public locate-node
  (lambda(node)
      (cog-outgoing-set (cog-execute!
        (BindLink
        (VariableNode "$go")
        (AndLink
          (MemberLink 
            node
            (VariableNode "$go"))
          (EvaluationLink
            (PredicateNode "GO_namespace")
            (ListLink
              (VariableNode "$go")
              (ConceptNode "cellular_component")))
        )
        (ExecutionOutputLink
        (GroundedSchemaNode "scm: filter-loc")
          (ListLink
            node
            (VariableNode "$go")
          )))
      ))
    )
)

;; filter only Cell membrane and compartments

(define-public (filter-loc node go)
  (let ([loc (string-downcase (find-name go))])
  (if (or (and (not (string-contains loc "complex")) 
      (or (string-suffix? "ome" loc) (string-suffix? "ome membrane" loc))) (is-compartment loc))
        (EvaluationLink
          (PredicateNode "has_location")
          (ListLink
            node
            (ConceptNode loc)
          )
        )
  )
  ))

(define (is-compartment loc)
  (let([compartments (list "vesicle" "photoreceptor" "plasma" "centriole" "cytoplasm" "endosome" "golgi" "vacuole" "granule" "endoplasmic" "mitochondri" "cytosol" "peroxisome" "ribosomes" "lysosome" "nucle")]
      [res #f])
    (for-each (lambda (comp)
      (if (string-contains loc comp)
        (set! res #t)
      )) compartments)
      (if res 
        #t
        #f
      )
  )
)

;; Add location of a gene/Molecule node in context of Reactome pathway

(define-public (add-loc node)
  (let ([child (cog-outgoing-atom node 0)] 
        [parent (cog-outgoing-atom node 1) ])
      (cog-outgoing-set (cog-execute!
        (BindLink
          (VariableNode "$loc")
          (AndLink
            (MemberLink 
              child
              parent)
            (EvaluationLink
              (PredicateNode "has_location")
              (ListLink
                child
                (VariableNode "$loc")))
          )
            (EvaluationLink
              (PredicateNode "has_location")
              (ListLink
                child
                (VariableNode "$loc")))
          )
        )
      )
    )
)

(define-public (find-subgroup name) 
    (let ((initial (string-split name #\:)))
        (match initial
            ((a b) a )
            ((a)
                (cond 
                    ((string-prefix? "R-HSA" a) "Reactome")
                    ((string-prefix? "SMP" a) "SMPDB")
                    (else "Genes")
                )
            )
        )
    )

)
;;a helper function to flatten a list, i.e convert a list of lists into a single list
(define-public (flatten x)
  (cond ((null? x) '())
        ((pair? x) (append (flatten (car x)) (flatten (cdr x))))
        (else (list x))))