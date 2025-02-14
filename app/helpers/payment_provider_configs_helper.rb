# frozen_string_literal: true

#  Copyright (c) 2021, Die Mitte Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

module PaymentProviderConfigsHelper
  def format_payment_provider(config)
    begin
      prefix = 'activerecord.attributes.payment_provider_config.payment_providers'
      t("#{prefix}.#{config.payment_provider}")
    rescue I18n::MissingTranslationData
      config.payment_provider
    end
  end
end
