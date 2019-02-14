;; load modules

(use-modules (opencog))
(use-modules (opencog python))
(use-modules (opencog query))
(use-modules (opencog exec))
(use-modules (opencog bioscience))
(use-modules (ice-9 textual-ports))

;; Create the main and Three independent atomspaces

(define current_as (cog-atomspace))
(define go_as (cog-new-atomspace))
(define pathway_as (cog-new-atomspace))
(define biogrid_as (cog-new-atomspace))

(display "Loading the dataset and necessary functions to do the annotation\n")

(cog-set-atomspace! current_as)

(primitive-load "annotation_request_handler.scm") 
(primitive-load "sample_data.scm")

;; Gene_go_annotation 

(cog-set-atomspace! go_as)

(primitive-load "annotation_request_handler.scm") 
(primitive-load "gene_go_annotation.scm")
(primitive-load "pm_functions.scm")

(MemberLink 
 	(GeneNode "SPAG9")
	(ConceptNode "GO:0001669"))

(EvaluationLink 
	 (PredicateNode "GO_namespace")
	 (ListLink 
		 (ConceptNode "GO:0001669")
		 (ConceptNode "cellular_component")
	 )
)

;; Gene_pathway_annotation 

(cog-set-atomspace! pathway_as)

(primitive-load "annotation_request_handler.scm") 

(primitive-load "gene_pathway_annotation.scm")
(primitive-load "pm_functions.scm")

(MemberLink
   (GeneNode "SPAG9")
   (ConceptNode "R-HSA-5684264")
)
 (MemberLink
   (MoleculeNode "Uniprot:Q8NFZ5")
   (ConceptNode "R-HSA-5684264")
)

(MemberLink
   (MoleculeNode "ChEBI:15996")
   (ConceptNode "R-HSA-5684264")
)

;; Biogrid interaction 

(cog-set-atomspace! biogrid_as)

(primitive-load "annotation_request_handler.scm") 

(primitive-load "biogrid_interaction_annotation.scm")
(primitive-load "pm_functions.scm")

(EvaluationLink
(PredicateNode "interacts_with")
(ListLink 
(GeneNode "SPAG9")
(GeneNode "SBNO1")))

(EvaluationLink
(PredicateNode "interacts_with")
(ListLink 
(GeneNode "SPAG9")
(GeneNode "SOX4")))

(EvaluationLink
(PredicateNode "interacts_with")
(ListLink 
(GeneNode "SPAG9")
(GeneNode "PPP4R2")))

(EvaluationLink
(PredicateNode "interacts_with")
(ListLink 
(GeneNode "SOX4")
(GeneNode "PPP4R2")))

(EvaluationLink
(PredicateNode "interacts_with")
(ListLink 
(GeneNode "PPP4R2")
(GeneNode "SOX4")))

 (EvaluationLink
   (PredicateNode "expresses")
   (ListLink
      (GeneNode "SPAG9")
      (MoleculeNode "Uniprot:P45985")
   )
)

 (EvaluationLink
   (PredicateNode "expresses")
   (ListLink
      (GeneNode "SBNO1")
      (MoleculeNode "Uniprot:P900")
   )
)


(display "started doing the annotation\n")

;; 1. Give list of genes space separated e.g "SLC1A5 SPARC"
(cog-set-atomspace! current_as)

(genes "SPAG9")

;; do three of the annotations

(do_annotation
(list
(cog-set-atomspace! go_as) (gene_go_annotation "biological_process cellular_component" 0)
(cog-set-atomspace! pathway_as) (gene_pathway_annotation "smpdb reactome" "True" "True")
(cog-set-atomspace! biogrid_as) (biogrid_interaction_annotation)
))


