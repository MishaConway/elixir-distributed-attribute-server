defmodule DistributedAttributeServer.States.State do
  defmacro __using__(_opts) do
    quote do
      use AttributeServer

      def marked?(component) do
        !!get(component)
      end

      def mark_component(component) do
        set component, %{}
      end

      def remove_component(component) do
        set component, false
      end
    end
  end
end
