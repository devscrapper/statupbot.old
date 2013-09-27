module VisitFactory
  module Publicities
    class Publicity
      class PublicityException < StandardError;
      end
      #---------------------------------------------------------------------------------------------------------------
      # l'existence du click pour une visit est calculé par enginebot suite aux exigences de statupweb.
      # statupweb définit pour chaque Policy :
      # - le taux de click par rapport aux nombre de visites qu'il projette de faire.
      # - la régie publicitaire utilisée par le site.
      #---------------------------------------------------------------------------------------------------------------
      # publicity :
      # permet de definir la regie publicitaire utilisée dans les pages du site
      # permet de définir si la visit doit cliquer sur une pub d'une des pages de la visit
      # permet de définir la durée de surf sur le site qui a exposé la pub, sur lequel on se debranche apres avoir cliquer sur la pub
      # permet de définir le nombre de page visitées sur le site qui a exposé la pub, sur lequel on se debranche apres avoir cliquer sur la pub
      #---------------------------------------------------------------------------------------------------------------
      # si la description de la visit contient : {"pub" = "none"} => aucune pub sera planifié
      # si la description de la visit contient : {"pub" = "adsens"} => le click sur une pub adsens sera planifié
      #---------------------------------------------------------------------------------------------------------------
      attr_reader :start_date_time,
                  :stop_date_time

      def self.build(pub_detail, start_date_time)
        case pub_detail[:advertising]
          when "none"
            return NoPublicity.new(start_date_time)
          when "adsens"
            return Adsense.new(start_date_time)
          else
            @@logger.an_event.warn "publicity #{pub_detail} unknown"
            return NoPublicity.new(start_date_time)
        end
      end

      def initialize(start_date_time, stop_date_time)
        @start_date_time = start_date_time
        @stop_date_time = stop_date_time
      end

      def unite(i, count=0)
        if i < 10
          count
        else
          unite(i.divmod(10)[0], count+1)
        end
      end

      def distributing(into, values, min_values_per_into)
        #p into
        #p values
        values_per_into = (values/into).to_i
        max_values_per_into = 2 * values_per_into - min_values_per_into
        res = Array.new(into, values_per_into)

        values.modulo(into).times { |i| res[i]+=1 } #au cas ou la div est un reste > 0 alors on perd des pages donc on les repartit n'importe ou.

        # si le value par into est egal à 2 ou
        # si le nombre de into <= à 2 alors il est impossible de calculer une distribution
        # alors on retourne un ensemble de into ayant un nombre de value egal à 2
        if values_per_into > min_values_per_into and
            into > 2
          plus = 0
          moins = 0

          (10 ** (unite(into) + 4)).times {
            ok = false
            while !ok
              plus = rand(res.size-1)
              moins = rand(res.size-1)
              if plus != moins and res[plus] < max_values_per_into and res[moins] > min_values_per_into
                ok = true
              end
            end
            res[plus] += 1
            res[moins] -= 1

          }
        end
        res
      end
    end
  end
end

require_relative 'adsense'
require_relative 'no_publicity'