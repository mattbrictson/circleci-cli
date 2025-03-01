# frozen_string_literal: true

module CircleCI
  module CLI
    module Command
      class BuildRepository
        def initialize(username, reponame)
          @username = username
          @reponame = reponame
          @builds = Response::Build.all(@username, @reponame)
          @build_numbers_shown = @builds.select(&:finished?).map(&:build_number)
        end

        def update
          @builds = (Response::Build.all(@username, @reponame) + @builds)
                    .uniq(&:build_number)
        end

        def mark_as_shown(build_number)
          @build_numbers_shown = (@build_numbers_shown + [build_number]).uniq
        end

        def builds_to_show
          @builds
            .reject { |build| @build_numbers_shown.include?(build.build_number) }
            .sort_by(&:build_number)
        end

        def build_for(build_number)
          @builds.find { |build| build.build_number == build_number }
        end
      end
    end
  end
end
