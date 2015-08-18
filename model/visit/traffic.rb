require 'uuid'
require 'uri'
require 'regexp-examples'
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
  # k : cardinalité de l'ensemble des combinaisons du mot clé final (celui permet atterrissage sur landing page) ; le mot clé
  # final est issu du fichier yaml de la visite. ; le nombre de recherche est donc egal au nombre de mot clé disponible ; pour ne pas
  # effectué trop de recherche, ni tj le même nombre, il sera calculé aléatoirement.
  # k = 31 ou 15 ou 7 ou 3 (voir ci-dessous)
  # on élimine le mot clé final C(i,i) qui est utilisé pour déterminer le landing url donc k - 1
  # il reste alors k-1 valeur de mot clé differentes parmi les combinaison
  # si le mot clé est composé d'un seul mot alors C(1,1) = 1 ; on conserve la valeur pour déterminer la landing donc  k > 1
  # en conclusion : le nombre de recherche est aléatoire entre {1,k-1}  et k > 1
  # p : nombre max de pages visitées lors du random surf qui précède la visite ; p = 3 ; sa valeur sera calculé aléaoirement entre {1,3}
  # q : nombre max de pages de resultats lors du random surf qui précède la visite ; q = 3 : sa valeur sera calculé aléaoirement entre {1,3}
  # f : index de la page de resultats du MDR dans laquelle on trouve le lien de la landing page. ; issu du fichier yaml
  # de la visite
  #--------------------------------------------------------------------------------------------------------------------
  # type    | random search | random suf | referrer | advertising | expression reguliere
  #--------------------------------------------------------------------------------------------------------------------
  # traffic | NON           | NON        | Direct   | NON         | aE{i-1}
  # traffic | OUI           | OUI        | Referral | NON         | b((2+0A{1,q-1}CG{1,p-1})f){k}1A{f-1}I(G{1,p}e){x}DE{i-1}
  # traffic | OUI           | OUI        | Search   | NON         | b((2+0A{1,q-1}CG{1,p-1})f){k}1A{f-1}DE{i-1}
  #--------------------------------------------------------------------------------------------------------------------
  #----------------------------------------------------------------------------------------------------------------
  # Calcul des fakes keyword
  # c'est une combinaison des mot du keyword.
  # en fonction du nombre de mots du keyword on sélectionne certaines combinaison
  # C(1,5) = 5, C(2,5) = 10, C(3,5) = 10, C(4,5) = 5, C(5,5) = 1  => 31 combinaisons
  # C(1,4) = 4, C(2,4) = 6, C(3,4) = 4, C(4,4) = 1 => 15 combinaisons
  # C(1,3) = 3, C(2,3) = 3, C(3,3) = 1 => 7 combinaisons
  # C(1,2) = 2, C(2,2) = 1 => 3 combinaisons
  # C(1,1) = 1 => 1 combinaison
  # on supprime les combinaisons C(i,i) = 1 car le nombre de mot max est utilisé pour retrouver dans les resultats
  # le landing
  # pour eviter un trop grand nombre de recherche qd le nombre de mot dans keyword est grand (max 5) on sélectionne
  # les combinaisons comme suit en répartissant les keyword entre la recherche sans click sur un lien des resultats
  # et la recherche avec click sur un lien de résultat
  # si nb de mot de keyword = 1 alors pas de recherche sans click et une recherche avec click
  # si nb de mot de keyword = 2 alors pas de recherche sans click et 2 recherches avec click avec combinaison de 1 mot par keyword
  # si nb de mot de keyword = 3 alors
  #                                   Random(1,3) de recherche sans click avec combinaison de 1 mot par keyword
  #                                   Random(1,3) de recherche avec click avec combinaison de 2 mots par keyword
  # si nb de mot de keyword = 4 alors
  #                                   Random(1,6) de recherche sans click avec combinaison de 2 mots par keyword
  #                                   Random(1,4) de recherche avec click avec combinaison de 3 mots par keyword
  # si nb de mot de keyword = 5 alors
  #                                   Random(1,10) de recherche sans click avec combinaison de 3 mots par keyword
  #                                   Random(1,5) de recherche avec click avec combinaison de 4 mots par keyword
  #----------------------------------------------------------------------------------------------------------------
  class Traffic < Visit

    def initialize(visit_details, website_details)
      begin
        super(visit_details, website_details)

        if @referrer.is_a?(Direct)
          i = @durations.size
          @regexp = "aE{#{i-1}}"
          @actions = /#{@regexp}/.random_example

        elsif @referrer.is_a?(Referral)
          raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "k"}) if @referrer.fake_keywords.nil? or @referrer.fake_keywords.size == 0
          raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "f"}) if @referrer.durations.size == 0
          raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "i"}) if @durations.size == 0
          raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "x"}) if @referrer.referral_uri_search.nil?
          raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "x"}) if @referrer.page_url.nil?

          i = @durations.size
          k = @referrer.fake_keywords.size > 1 ? Random.new.rand(1 .. @referrer.fake_keywords.size - 1) : 0
          f = @referrer.durations.size
          q = 3
          p = 3
          # si referral_uri_search == page_uri.to_s alors selectionne directement le landing link sur la page du referral.
          # si referral_uri_search != page_uri.to_s alors surf qq page sur le site referral avant de se debrancher vers la page du referral qui contient le landing link(page_url)
          if @referrer.page_url.to_s == @referrer.referral_uri_search.url
            x = 0
          else
            x = 1
          end

          @regexp = "b((2|0A{1,#{q-1}}CG{1,#{p-1}})f){#{k}}1A{#{f-1}}I(G{1,#{p}}e){#{x}}DE{#{i-1}}"
          @@logger.an_event.debug "@regexp #{@regexp}"

          @actions = /#{@regexp}/.random_example
          @@logger.an_event.debug "@actions #{@actions}"

        elsif @referrer.is_a?(Search)
          raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "k"}) if @referrer.fake_keywords.nil? or @referrer.fake_keywords.size == 0
          raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "f"}) if @referrer.durations.size == 0
          raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "i"}) if @durations.size == 0

          i = @durations.size
          k = @referrer.fake_keywords.size > 1 ? Random.new.rand(1 .. @referrer.fake_keywords.size - 1) : 0
          f = @referrer.durations.size
          q = 3
          p = 3
          @regexp = "b((2|0A{1,#{q-1}}CG{1,#{p-1}})f){#{k}}1A{#{f-1}}DE{#{i-1}}"

          @@logger.an_event.debug "count page visit (i) : #{i}"
          @@logger.an_event.debug "count non finaly search (k) : #{k}"
          @@logger.an_event.debug "index result page finaly search (f) : #{f}"
          @@logger.an_event.debug "count page non finaly surf (p) : #{p}"
          @@logger.an_event.debug "count result page non finaly search (q) : #{q}"
          @@logger.an_event.debug "@regexp #{@regexp}"

          @actions = /#{@regexp}/.random_example
          @@logger.an_event.debug "@actions #{@actions}"
        else

        end

      rescue Exception => e

        @@logger.an_event.fatal e.message
        raise e

      else
        @@logger.an_event.debug "visit traffic #{@id} initialize"

      ensure

      end
    end
  end

end