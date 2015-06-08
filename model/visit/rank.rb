require 'uuid'
require 'uri'
require_relative '../../lib/error'
require_relative '../../lib/logging'


module Visits
  #--------------------------------------------------------------------------------------------------------------------
  # Liste des expressions regulieres en fonction du type de visite (:traffic, :advert, :rank)
  # Type visit :
  # :adword : permet de générer du revenu adword à partir d’un site
  # :Traffic : permet de générer du traffic sur un site
  # :Rank : permet de diminuer la position d’un site dans les résultats de recherche google.
  #
  # Random  search : réalise une recherche aléatoire avec un ensemble de mots clé au moyen d’un moteur de recherche
  # Random  surf : réalise une navigation aléatoire sur un site non maitrisé.
  #--------------------------------------------------------------------------------------------------------------------
  # variables utilisées dans les expressions regulieres :
  # i : nombre de pages de la visite ; issu du fichier yaml de la visite
  # j : nombre de pages visitée lors du random surf chez l'advertiser ; issu du fichier yaml de la visite
  # k : cardinalité de l'ensemble des sous chaines du mot clé final (permet atterrissage sur landing page) ; le mot clé
  # final est issu du fichier yaml de la visite ; l'ensemble des sous-chaine est calculé ; la répartition entre k' et k''
  # est aléatoire.
  #     k = k'' + k'
  # p : nombre de pages visitées lors du random surf qui précède la visite ; calculé aléaoirement entre [1-3]
  # f : index de la page de resultats du MDR dans laquelle on trouve le lien de la landing page. ; issu du fichier yaml
  # de la visite
  # q : nombre de sites visités par page de resultats du MDR avant de passer à la visite ; calculé aléaoirement entre [2-5]
  #--------------------------------------------------------------------------------------------------------------------
  # type    | random search | random suf | referrer | advertising | expression reguliere
  #--------------------------------------------------------------------------------------------------------------------
  # rank    | OUI           | NON        | Search   | NON         | b1((Cc){2,5}A){f-1}(Cc){2,5}DE{i-1}
  #--------------------------------------------------------------------------------------------------------------------
  class Rank < Visit

    def initialize (visit_details)
      begin
        super
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "f"}) if @referrer.durations.size == 0
        raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "i"}) if @durations.size == 0

        i = @durations.size
        f = @referrer.durations.size

        @regexp ="b1((Cc){#{2},#{5}}A){#{f-1}}(Cc){#{2},#{5}}DE{#{i-1}}"

        @@logger.an_event.debug "i #{i}"
        @@logger.an_event.debug "f #{f}"

        @@logger.an_event.debug "@regexp #{@regexp}"

        @actions = /#{@regexp}/.random_example
        @@logger.an_event.debug "@actions #{@actions}"

      rescue Exception => e

        @@logger.an_event.fatal e.message
        raise e

      else
        @@logger.an_event.info "visit rank #{@id} has #{@actions.size} actions : #{@actions}"

      ensure

      end
    end
  end

end