require_dependency 'redmine/scm/adapters/git_adapter'

module RedmineDiffEmail
  module Patches
    module GitAdapterPatch

      def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable
        end
      end

      module InstanceMethods

        def changed_files(path = nil, rev = 'HEAD')
          path ||= ''
          cmd_args = []
          cmd_args << 'log' << '--no-color' << '--pretty=format:%cd' << '--name-status' << '-1' << rev
          cmd_args << '--' <<  scm_iconv(@path_encoding, 'UTF-8', path) unless path.empty?
          changed_files = []
          git_cmd(cmd_args) do |io|
            io.each_line do |line|
              changed_files << line
            end
          end
          changed_files
        end

      end

    end
  end
end

unless Redmine::Scm::Adapters::GitAdapter.included_modules.include?(RedmineDiffEmail::Patches::GitAdapterPatch)
  Redmine::Scm::Adapters::GitAdapter.send(:include, RedmineDiffEmail::Patches::GitAdapterPatch)
end
