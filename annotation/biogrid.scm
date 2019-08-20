;;; MOZI-AI Annotation Scheme
;;; Copyright © 2019 Abdulrahman Semrie
;;; Copyright © 2019 Hedra Seid
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
(define-module (annotation biogrid)
	#:use-module (annotation functions)
	#:use-module (annotation util)
    #:use-module (opencog)
    #:use-module (opencog query)
    #:use-module (opencog exec)
    #:use-module (opencog bioscience)
)
(define-public (biogrid-interaction-annotation gene-nodes interaction)
  (let ([result (list (ConceptNode "biogrid-interaction-annotation"))])
	
	(for-each (lambda (gene)
		(if (equal? interaction "Proteins")
			(set! result (append result  (match-gene-interactors (GeneNode gene)  1) (find-protein-interactor (GeneNode gene) (Number 1))  (find-output-interactors (GeneNode gene))))
		)

		(if (equal? interaction "Genes") 
			(begin
				(set! result (append result  (match-gene-interactors (GeneNode gene) 0) (find-output-interactors (GeneNode gene))))
			)
		)
	) gene-nodes)

	(ListLink result)
  )

)