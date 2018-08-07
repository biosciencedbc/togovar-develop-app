module Reports
  class VariantController < ApplicationController
    def show(id)
      id.sub!('tgv', '') # TODO: remove when RDF updated
      @tgv_id = id

      @stanza = []

      @stanza << Stanza.row_headered_table(nil,
                                           nav_id:    'variant_information',
                                           nav_label: 'Variant Information',
                                           args:      {
                                             url: variant_information
                                           })
      @stanza << Stanza.variant_frequency('Frequency', args: { url1: variant_frequency, url2: variant_exac_frequency })
      @stanza << Stanza.variant_jbrowse('Genomic context', args: { url: variant_jbrowse_position })
      @stanza << Stanza.column_headered_table('Transcripts', args: { url: transcripts })

      lookup = Lookup.find(id)

      if (allele_id = lookup&.clinvar&.allele_id)
        variation_id = Reports::Variant.variation_id_for_allele(allele_id)
        @stanza << Stanza.clinvar_variant_information('Variant Information', args: { clinvar_id: variation_id })
        @stanza << Stanza.clinvar_variant_interpretation('Variant Interpretation', args: { clinvar_id: variation_id })
        @stanza << Stanza.clinvar_variant_alleles('Variant Alleles', args: { clinvar_id: variation_id })
      end

      if (rs = lookup&.rs)
        Array(rs).each do |x|
          @stanza << Stanza.variant_publications("Publications (#{x})",
                                                 nav_id:    "publication_#{x}",
                                                 nav_label: 'Publications',
                                                 args:      { url: variant_publications(x) })
        end
      end
    end

    private

    def variant_frequency
      URI.join(root_url, "/sparqlist/api/variant_frequency?tgv_id=#{@tgv_id}").to_s
    end

    def variant_exac_frequency
      URI.join(root_url, "/sparqlist/api/variant_exac_frequency?tgv_id=#{@tgv_id}").to_s
    end

    def variant_jbrowse_position
      URI.join(root_url, "/sparqlist/api/variant_jbrowse_position?tgv_id=#{@tgv_id}").to_s
    end

    def variant_information
      URI.join(root_url, "/sparqlist/api/variant_basic_information?tgv_id=#{@tgv_id}").to_s
    end

    def transcripts
      URI.join(root_url, "/sparqlist/api/variant_transcripts?tgv_id=#{@tgv_id}").to_s
    end

    def variant_publications(rs)
      URI.join(root_url, "/sparqlist/api/rs2disease?rs=#{rs}").to_s
    end
  end
end
