require 'uri'
require_relative '../../../lib/error'
module Visits
  #----------------------------------------------------------------------------------------------------------------
  # Calcul des fakes keyword
  # c'est une combinaison des mot du keyword.
  # en fonction du nombre de mots du keyword on sélectionne certaines combinaison
  # C(1,5) = 5, C(2,5) = 10, C(3,5) = 10, C(4,5) = 5, C(5,5) = 1
  # C(1,4) = 4, C(2,4) = 6, C(3,4) = 4, C(4,4) = 1
  # C(1,3) = 3, C(2,3) = 3, C(3,3) = 1
  # C(1,2) = 2, C(2,2) = 1
  # C(1,1) = 1
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
  module Referrers
    class Referral < Referrer

      attr :page_url, # URI de la page referral
           :duration

      include Errors



      def initialize(referer_details)


        begin

          raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "referral_path"}) if referer_details[:referral_path].nil?
          raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "duration"}) if referer_details[:duration].nil?
          raise Error.new(ARGUMENT_UNDEFINE, :values => {:variable => "source"}) if referer_details[:source].nil?

          super(landing_page)
          @keywords = referer_details[:keyword]

          arr = @keywords.split (" ")
          case @keywords.size
            when 1
              @fake_keywords1 = []
              @fake_keywords2 = [] << @keywords
            when 2
              @fake_keywords1 = []
              @fake_keywords2 = arr.combination(1).to_a
            when 3
              @fake_keywords1 = arr.combination(1).to_a
              @fake_keywords2 = arr.combination(2).to_a
            when 4
              @fake_keywords1 = arr.combination(2).to_a
              @fake_keywords2 = arr.combination(3).to_a
            when 5
              @fake_keywords1 = arr.combination(3).to_a
              @fake_keywords2 = arr.combination(4).to_a
            else

          end


          @random_search_min = referer_details[:random_search][:min]
          @random_search_max =referer_details[:random_search][:max]
          @random_surf_min =referer_details[:random_surf][:min]
          @random_surf_max = referer_details[:random_surf][:max]
          @page_url = referer_details[:source].start_with?("http:") ?
              URI.join(referer_details[:source], referer_details[:referral_path]) :
              URI.join("http://#{referer_details[:source]}", referer_details[:referral_path])
          @duration = referer_details[:duration]

        rescue Exception => e
          @@logger.an_event.error e.message
          raise Error.new(REFERRER_NOT_CREATE, :error => e)

        else
          @@logger.an_event.debug "referral create"

        ensure

        end
      end


      def to_s
        super.to_s +
        "page url : #{@page_url} \n" +
        "duration : #{@duration} \n"
      end
    end
  end
end
