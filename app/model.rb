# frozen_string_literal: true

# Model module
module Model
  # This ensures that we encapsulate the logic within the `Model` module.
end

# Load dependent models
require 'model/credential'  # Make sure credential model is loaded first
require 'model/plan'        # Plan depends on credential, so this must be loaded after
