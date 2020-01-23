(use-modules (opencog) (opencog exec))

(use-modules (annotation functions)) ;;; for find-pubmed-id

(define biogrid_interaction_rule
    (BindLink
        (VariableList
            (TypedVariable (Variable "$g") (Type "GeneNode"))
            (TypedVariable (Variable "$gg") (Type "GeneNode"))
            (TypedVariable (Variable "$ggg") (Type "GeneNode"))
        ) 
        (And
            (EvaluationLink
                (PredicateNode "has_current_symbol")
                (ListLink
                    (Variable "$g")
                    (Variable "$gg")))
            (EvaluationLink
                (PredicateNode "interacts_with")
                (ListLink
                    (Variable "$g")
                    (Variable "$ggg")
                )
            )
	    )
        (ListLink
            (EvaluationLink
                (PredicateNode "has_pubmedID")
                (ListLink
                (EvaluationLink
                    (PredicateNode "interacts_with")
                    (ListLink
                        (Variable "$gg")
                        (Variable "$ggg")
                    )
                )
                (find-pubmed-id (Variable "$g") (Variable "$ggg"))
                )
            )
            (DeleteLink
                (EvaluationLink
                        (PredicateNode "interacts_with")
                        (ListLink
                            (Variable "$g")
                            (Variable "$ggg")
                        )
                )
                (EvaluationLink
                        (PredicateNode "interacts_with")
                        (ListLink
                            (Variable "$ggg")
                            (Variable "$g")
                        )
                )
            )
        )
    )
)
(define member_rule
    (BindLink
        (VariableList
            (TypedVariable (Variable "$g") (Type "GeneNode"))
            (TypedVariable (Variable "$gg") (Type "GeneNode"))
            (TypedVariable (Variable "$c") (Type "ConceptNode"))
        ) 
        (And
            (EvaluationLink
                (PredicateNode "has_current_symbol")
                (ListLink
                    (Variable "$g")
                    (Variable "$gg")))
            (MemberLink
                (Variable "$g")
                (Variable "$c"))
	    )
        (ListLink
            (MemberLink
                (Variable "$gg")
                (Variable "$c"))
            (DeleteLink
                (MemberLink
                    (Variable "$g")
                    (Variable "$c"))
            )
        )
    )
)
(define expresses_rule
    (BindLink
        (VariableList
            (TypedVariable (Variable "$g") (Type "GeneNode"))
            (TypedVariable (Variable "$gg") (Type "GeneNode"))
            (TypedVariable (Variable "$m") (Type "MoleculeNode"))
        ) 
        (And
            (EvaluationLink
                (PredicateNode "has_current_symbol")
                (ListLink
                    (Variable "$g")
                    (Variable "$gg")))
            (EvaluationLink
                (PredicateNode "expresses")
                (ListLink
                    (Variable "$g")
                    (Variable "$m")))
	    )
        (ListLink
            (EvaluationLink
                (PredicateNode "expresses")
                (ListLink
                    (Variable "$gg")
                    (Variable "$m")))
            (DeleteLink
                (EvaluationLink
                    (PredicateNode "expresses")
                    (ListLink
                        (Variable "$g")
                        (Variable "$m")))
            )
        )
    )
)
(define location_rule
    (BindLink
        (VariableList
            (TypedVariable (Variable "$g") (Type "GeneNode"))
            (TypedVariable (Variable "$gg") (Type "GeneNode"))
            (TypedVariable (Variable "$l") (Type "ConceptNode"))
        ) 
        (And
            (EvaluationLink
                (PredicateNode "has_current_symbol")
                (ListLink
                    (Variable "$g")
                    (Variable "$gg")))
            (EvaluationLink (stv 1 1)
                (PredicateNode "has_location")
                (ListLink
                    (Variable "$g")
                    (Variable "$l")))
        )
        (ListLink
            (EvaluationLink (stv 1 1)
                (PredicateNode "has_location")
                (ListLink
                (Variable "$gg")
                (Variable "$l")
                ))
            (DeleteLink
                (EvaluationLink (stv 1 1)
                    (PredicateNode "has_location")
                    (ListLink
                        (Variable "$g")
                        (Variable "$l")))
            )
        )
    )
)
(define name_rule
    (BindLink
        (VariableList
            (TypedVariable (Variable "$g") (Type "GeneNode"))
            (TypedVariable (Variable "$gg") (Type "GeneNode"))
            (TypedVariable (Variable "$n") (Type "ConceptNode"))
        ) 
        (And
            (EvaluationLink
                (PredicateNode "has_current_symbol")
                (ListLink
                    (Variable "$g")
                    (Variable "$gg")))
            (EvaluationLink (stv 1 1)
                (PredicateNode "has_name")
                (ListLink
                    (Variable "$g")
                    (Variable "$n")))
        )
        (ListLink
            (EvaluationLink (stv 1 1)
                (PredicateNode "has_name")
                (ListLink
                (Variable "$gg")
                (Variable "$n")
                ))
            (DeleteLink
                (EvaluationLink (stv 1 1)
                    (PredicateNode "has_name")
                    (ListLink
                        (Variable "$g")
                        (Variable "$n")))
            )
        )
    )
)
(define biogird_id_rule
    (BindLink
        (VariableList
            (TypedVariable (Variable "$g") (Type "GeneNode"))
            (TypedVariable (Variable "$gg") (Type "GeneNode"))
            (TypedVariable (Variable "$b") (Type "ConceptNode"))
        ) 
        (And
            (EvaluationLink
                (PredicateNode "has_current_symbol")
                (ListLink
                    (Variable "$g")
                    (Variable "$gg")))
            (EvaluationLink (stv 1 1)
                (PredicateNode "has_biogridID")
                (ListLink
                    (Variable "$g")
                    (Variable "$b")))
        )
        (ListLink        
            (EvaluationLink (stv 1 1)
                (PredicateNode "has_biogridID")
                (ListLink
                (Variable "$gg")
                (Variable "$b")
                ))
            (DeleteLink
                (EvaluationLink (stv 1 1)
                    (PredicateNode "has_biogridID")
                    (ListLink
                        (Variable "$g")
                        (Variable "$b")))
            )
        )
    )
)
(define entrez_id_rule
    (BindLink
        (VariableList
            (TypedVariable (Variable "$g") (Type "GeneNode"))
            (TypedVariable (Variable "$gg") (Type "GeneNode"))
            (TypedVariable (Variable "$e") (Type "ConceptNode"))
        ) 
        (And
            (EvaluationLink
                (PredicateNode "has_current_symbol")
                (ListLink
                    (Variable "$g")
                    (Variable "$gg")))
            (EvaluationLink (stv 1 1)
                (PredicateNode "has_entrez_id")
                (ListLink
                    (Variable "$g")
                    (Variable "$e")))
        )
        (ListLink        
            (EvaluationLink (stv 1 1)
                (PredicateNode "has_entrez_id")
                (ListLink
                (Variable "$gg")
                (Variable "$e")
                ))
            (DeleteLink
                (EvaluationLink (stv 1 1)
                    (PredicateNode "has_entrez_id")
                    (ListLink
                        (Variable "$g")
                        (Variable "$e")))
            )
        )
    )
)
(define pathway_biogrid_crossannotation_rule
    (BindLink
        (VariableList
            (TypedVariable (VariableNode "$g") (Type 'GeneNode))
            (TypedVariable (VariableNode "$g1") (Type 'GeneNode))
            (TypedVariable (VariableNode "$g2") (Type 'GeneNode))
            (TypedVariable (VariableNode "$pw") (Type 'ConceptNode))
            (TypedVariable (VariableNode "$p1") (Type 'MoleculeNode))
            (TypedVariable (VariableNode "$p2") (Type 'MoleculeNode)))
    (AndLink
        (MemberLink (VariableNode "$g") (VariableNode "$pw"))
        (MemberLink (VariableNode "$p1") (VariableNode "$pw"))
        (MemberLink (VariableNode "$p2") (VariableNode "$pw"))
        (EvaluationLink (PredicateNode "expresses") (ListLink (VariableNode "$g1") (VariableNode "$p1")))
        (EvaluationLink (PredicateNode "expresses") (ListLink (VariableNode "$g2") (VariableNode "$p2")))
        (EvaluationLink (PredicateNode "interacts_with") (ListLink (VariableNode "$g1") (VariableNode "$g2")))
    )
     (ExecutionOutputLink
     (GroundedSchemaNode "scm: generate-interactors")
	 	(ListLink
             (VariableNode "$g")
             (VariableNode "$pw")
             (VariableNode "$g1")
	 	    (VariableNode "$g2")
	 	  ))
    )
)
(define (generate-interactors gene concept gene1 gene2)
    (if (string-prefix? "GO:" (cog-name concept))
        (ListLink)
        (EvaluationLink
            (PredicateNode "has_biogrid_crossannotation")
            (ListLink
                gene
                (EvaluationLink
                (PredicateNode "has_pubmedID")
                    (ListLink 
                        (EvaluationLink (PredicateNode "interacts_with") (ListLink gene1 gene2))
                        (find-pubmed-id gene1 gene2)  
                    )
                )
            )
        )
    )
)

(cog-execute! biogrid_interaction_rule)
(cog-execute! member_rule)
(cog-execute! expresses_rule)
(cog-execute! name_rule)
(cog-execute! location_rule)
(cog-execute! biogird_id_rule)
(cog-execute! entrez_id_rule)
(cog-execute! pathway_biogrid_crossannotation_rule)
