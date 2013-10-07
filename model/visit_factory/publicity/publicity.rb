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
      # si la description de la visit contient : {"pub" = "adsens"} => le click sur une pub adsens sera planifié avec un comprtement par défaut
      # si la description de la visit contient : {"pub" = "adsens", "count_page" = "5..15", "duration_visit" = "10..30"(en mn), "local" = "80"}
      # => le click sur une pub adsens sera planifié avec un comportement spécialisé par les paramètres présents, sinon pour ceux absents le comportement sera celui par defaut
      # "percent_local_page" = "80", signifie que que 80% des pages visites seront locales au site, les 20% dernières pourront être hors du site.
      #---------------------------------------------------------------------------------------------------------------
      DURATION_VISIT_MIN = 60 # duree minimale d'une visite sur le site de l'advertiser

      attr_reader :start_date_time,
                  :stop_date_time,
                  :duration_pages,
                  :around_pages

      def self.build(pub_detail, start_date_time)
        #TODO  meo {"pub" = "adsens", "count_page" = "5..15", "duration_visit" = "10..30"(en mn), "percent_local_page" = "80"}
        case pub_detail[:advertising]
          when "none"
            return NoPublicity.new(start_date_time)
          when "adsense"
            return Adsense.new(start_date_time, pub_detail)
          else
            @@logger.an_event.debug "pub details #{pub_detail}"
            @@logger.an_event.warn "publicity #{pub_detail[:advertising]} unknown"
            return NoPublicity.new(start_date_time)
        end
      end

      def initialize(start_date_time, pub_detail)
        if pub_detail[:count_page].nil?
          count_page = Random.new.rand(5..15) # le nombre de page de la visit est compris entre 5 & 15 par defaut
        else
          count_page = Random.new.rand(eval(pub_detail[:count_page]))
        end
        if pub_detail[:duration_visit].nil?
          duration_visit = Random.new.rand(5..15) # la durée de la visit est comprise en tre 10 & 30 mn par defaut
        else
          duration_visit = Random.new.rand(eval(pub_detail[:duration_visit]))
        end
        if pub_detail[:percent_local_page].nil?
          percent_local_page = 80 # le pourcentage de page de la visite chez l'advertiser qui resteront sur le site de l'advertiser par deafaut
        else
          percent_local_page = eval(pub_detail[:percent_local_page])
        end

        @duration_pages = distributing(count_page, duration_visit * 60, DURATION_VISIT_MIN)
        @around_pages = Array.new(count_page).fill(:not_local).fill(:local, 0, (count_page * percent_local_page/100).round(0))
        @start_date_time = start_date_time
        @stop_date_time = start_date_time + duration_visit * 60
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

      def plan(scheduler, visitor_id)
        begin
          scheduler.at @start_date_time do
            VisitorFactory.click_pub(visitor_id, @duration_pages, @around_pages, eval(self.class.name)::ADVERTISING, @@logger)
          end
          @@logger.an_event.info "click on publicity #{self.class} is planed at #{@start_date_time}"
        rescue Exception => e
          @logger.an_event.debug e
          @@logger.an_event.error "cannot plan click on publicity #{self.class}"
          raise RessourceException, e.message
        end
      end
    end
  end
end

require_relative 'adsense'
require_relative 'no_publicity'