module Swagger
  module Blocks
    module InternalHelpers
      # Return [root_node, api_node_map] from all of the given swaggered_classes.
      def self.parse_swaggered_classes(swaggered_classes)
        root_nodes = []

        api_node_map = {}
        models_nodes = []

        path_node_map = {}
        schema_node_map = {}
        swaggered_classes.each do |swaggered_class|
          next unless swaggered_class.respond_to?(:_swagger_nodes, true)
          swagger_nodes = swaggered_class.send(:_swagger_nodes)
          root_node = swagger_nodes[:root_node]
          if root_node
            if root_nodes.empty?
              root_nodes.append(root_node)
            else
              root = root_nodes.first
              root_node.data.each do |key, value|
                unless root.data[key]
                  root.key(key, value)
                  next
                # TODO: else also assign the value. except for Node
                end
                if value.is_a?(Node)
                  root.data[key].keys(value.data)
                end
              end
            end
          end

          # 2.0
          if swagger_nodes[:path_node_map]
            path_node_map.merge!(swagger_nodes[:path_node_map])
          end
          if swagger_nodes[:schema_node_map]
            schema_node_map.merge!(swagger_nodes[:schema_node_map])
          end
        end
        data = {root_node: self.ensure_root_node(root_nodes)}
        if data[:root_node].is_swagger_2_0?
          data[:path_nodes] = path_node_map
          data[:schema_nodes] = schema_node_map
        else
          data[:api_node_map] = api_node_map
          data[:models_nodes] = models_nodes
        end
        data
      end

      # Make sure there is exactly one root_node and return it.
      # TODO should this merge the contents of the root nodes instead?
      def self.ensure_root_node(root_nodes)
        if root_nodes.length == 0
          raise Swagger::Blocks::DeclarationError.new(
            'swagger_root must be declared')
        end
        root_nodes.first
      end
    end
  end
end
