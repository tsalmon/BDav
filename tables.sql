-- Database generated with pgModeler (PostgreSQL Database Modeler).
-- PostgreSQL version: 9.3
-- Project Site: pgmodeler.com.br
-- Model Author: ---

SET check_function_bodies = false;
-- ddl-end --


-- Database creation must be done outside an multicommand file.
-- These commands were put in this file only for convenience.
-- -- object: nouvelle_base | type: DATABASE --
-- CREATE DATABASE nouvelle_base
-- ;
-- -- ddl-end --
-- 

-- object: public.client | type: TABLE --
CREATE TABLE public.client(
	id_client varchar NOT NULL DEFAULT 0,
	nom smallint,
	CONSTRAINT client_pk PRIMARY KEY (id_client)

);
-- ddl-end --
-- object: public.compte | type: TABLE --
CREATE TABLE public.compte(
	"IBAN" varchar NOT NULL,
	solde smallint,
	"BIC_banque" varchar NOT NULL,
	CONSTRAINT compte_pk PRIMARY KEY ("IBAN")

);
-- ddl-end --
-- object: public.particulier | type: TABLE --
CREATE TABLE public.particulier(
	age smallint,
	CONSTRAINT particulier_pk PRIMARY KEY (id_client)

) INHERITS(public.client)
;
-- ddl-end --
-- object: public.organisation | type: TABLE --
CREATE TABLE public.organisation(
,
	CONSTRAINT organisation_pk PRIMARY KEY (id_client)

) INHERITS(public.client)
;
-- ddl-end --
-- object: public.virement | type: TABLE --
CREATE TABLE public.virement(
	num_transaction smallint NOT NULL,
	beneficiaire varchar NOT NULL,
	emeteur varchar NOT NULL,
	montant smallint,
	CONSTRAINT transaction_pk PRIMARY KEY (num_transaction)

);
-- ddl-end --
-- object: public.carte | type: TABLE --
CREATE TABLE public.carte(
	num_carte integer,
	"IBAN_compte" varchar NOT NULL,
	CONSTRAINT carte_pk PRIMARY KEY (num_carte)

);
-- ddl-end --
-- object: compte_fk | type: CONSTRAINT --
ALTER TABLE public.carte ADD CONSTRAINT compte_fk FOREIGN KEY ("IBAN_compte")
REFERENCES public.compte ("IBAN") MATCH FULL
ON DELETE RESTRICT ON UPDATE CASCADE NOT DEFERRABLE;
-- ddl-end --


-- object: public.banque | type: TABLE --
CREATE TABLE public.banque(
	"BIC" varchar NOT NULL,
	taux_interet smallint,
	taux_decouvert smallint,
	nom_banque varchar,
	prix_virement smallint,
	prix_virement_permanent smallint,
	prix_virement_mensuel smallint,
	CONSTRAINT banque_pk PRIMARY KEY ("BIC")

);
-- ddl-end --
-- object: banque_fk | type: CONSTRAINT --
ALTER TABLE public.compte ADD CONSTRAINT banque_fk FOREIGN KEY ("BIC_banque")
REFERENCES public.banque ("BIC") MATCH FULL
ON DELETE RESTRICT ON UPDATE CASCADE NOT DEFERRABLE;
-- ddl-end --


-- object: public."Date" | type: TABLE --
CREATE TABLE public."Date"(
	date date NOT NULL,
	CONSTRAINT date_fk PRIMARY KEY (date)

);
-- ddl-end --
-- object: public.procuration | type: TABLE --
CREATE TABLE public.procuration(
	date_debut date,
	"IBAN_compte_particulier" varchar,
	id_client_particulier varchar NOT NULL DEFAULT 0,
	"IBAN_compte_pro" varchar,
	CONSTRAINT procuration_pk PRIMARY KEY (id_client_particulier)

);
-- ddl-end --
-- object: public.t_interdit_bancaire | type: TABLE --
CREATE TABLE public.t_interdit_bancaire(
	id_client_client varchar DEFAULT 0,
	"BIC_banque" varchar NOT NULL,
	date_interdit date DEFAULT NULL,
	date_regularisation date,
	motif varchar,
	CONSTRAINT t_interdit_bancaire_pk PRIMARY KEY (id_client_client)

);
-- ddl-end --
-- object: public.decouvert | type: TABLE --
CREATE TABLE public.decouvert(
	id_banque varchar,
	"IBAN_compte" varchar,
	CONSTRAINT decouvert_pk PRIMARY KEY ("IBAN_compte")

);
-- ddl-end --
-- object: public.virement_permanent | type: TABLE --
CREATE TABLE public.virement_permanent(
	date date,
	frequence smallint,
	CONSTRAINT virement_permanent_pk PRIMARY KEY (num_transaction)

) INHERITS(public.virement)
;
-- ddl-end --
-- object: public.compte_particulier | type: TABLE --
CREATE TABLE public.compte_particulier(
	id_client_particulier varchar NOT NULL DEFAULT 0,
	CONSTRAINT compte_particulier_pk PRIMARY KEY ("IBAN")

) INHERITS(public.compte)
;
-- ddl-end --
-- object: public.compte_pro | type: TABLE --
CREATE TABLE public.compte_pro(
	id_client_organisation varchar NOT NULL DEFAULT 0,
	CONSTRAINT compte_pro_pk PRIMARY KEY ("IBAN")

) INHERITS(public.compte)
;
-- ddl-end --
-- object: compte_particulier_fk | type: CONSTRAINT --
ALTER TABLE public.procuration ADD CONSTRAINT compte_particulier_fk FOREIGN KEY ("IBAN_compte_particulier")
REFERENCES public.compte_particulier ("IBAN") MATCH FULL
ON DELETE SET NULL ON UPDATE CASCADE NOT DEFERRABLE;
-- ddl-end --


-- object: particulier_fk | type: CONSTRAINT --
ALTER TABLE public.procuration ADD CONSTRAINT particulier_fk FOREIGN KEY (id_client_particulier)
REFERENCES public.particulier (id_client) MATCH FULL
ON DELETE RESTRICT ON UPDATE CASCADE NOT DEFERRABLE;
-- ddl-end --


-- object: particulier_fk | type: CONSTRAINT --
ALTER TABLE public.compte_particulier ADD CONSTRAINT particulier_fk FOREIGN KEY (id_client_particulier)
REFERENCES public.particulier (id_client) MATCH FULL
ON DELETE RESTRICT ON UPDATE CASCADE NOT DEFERRABLE;
-- ddl-end --


-- object: client_fk | type: CONSTRAINT --
ALTER TABLE public.t_interdit_bancaire ADD CONSTRAINT client_fk FOREIGN KEY (id_client_client)
REFERENCES public.client (id_client) MATCH FULL
ON DELETE RESTRICT ON UPDATE CASCADE NOT DEFERRABLE;
-- ddl-end --


-- object: t_interdit_bancaire_uq | type: CONSTRAINT --
ALTER TABLE public.t_interdit_bancaire ADD CONSTRAINT t_interdit_bancaire_uq UNIQUE (id_client_client);
-- ddl-end --


-- object: compte_fk | type: CONSTRAINT --
ALTER TABLE public.decouvert ADD CONSTRAINT compte_fk FOREIGN KEY ("IBAN_compte")
REFERENCES public.compte ("IBAN") MATCH FULL
ON DELETE RESTRICT ON UPDATE CASCADE NOT DEFERRABLE;
-- ddl-end --


-- object: decouvert_uq | type: CONSTRAINT --
ALTER TABLE public.decouvert ADD CONSTRAINT decouvert_uq UNIQUE ("IBAN_compte");
-- ddl-end --


-- object: organisation_fk | type: CONSTRAINT --
ALTER TABLE public.compte_pro ADD CONSTRAINT organisation_fk FOREIGN KEY (id_client_organisation)
REFERENCES public.organisation (id_client) MATCH FULL
ON DELETE RESTRICT ON UPDATE CASCADE NOT DEFERRABLE;
-- ddl-end --


-- object: compte_pro_fk | type: CONSTRAINT --
ALTER TABLE public.procuration ADD CONSTRAINT compte_pro_fk FOREIGN KEY ("IBAN_compte_pro")
REFERENCES public.compte_pro ("IBAN") MATCH FULL
ON DELETE SET NULL ON UPDATE CASCADE NOT DEFERRABLE;
-- ddl-end --


-- object: banque_fk | type: CONSTRAINT --
ALTER TABLE public.t_interdit_bancaire ADD CONSTRAINT banque_fk FOREIGN KEY ("BIC_banque")
REFERENCES public.banque ("BIC") MATCH FULL
ON DELETE RESTRICT ON UPDATE CASCADE NOT DEFERRABLE;
-- ddl-end --


-- object: transaction_emmeteur_fk | type: CONSTRAINT --
ALTER TABLE public.virement ADD CONSTRAINT transaction_emmeteur_fk FOREIGN KEY (emeteur)
REFERENCES public.compte ("IBAN") MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION NOT DEFERRABLE;
-- ddl-end --


-- object: transaction_beneficiaire_varchar | type: CONSTRAINT --
ALTER TABLE public.virement ADD CONSTRAINT transaction_beneficiaire_varchar FOREIGN KEY (beneficiaire)
REFERENCES public.compte ("IBAN") MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION NOT DEFERRABLE;
-- ddl-end --



