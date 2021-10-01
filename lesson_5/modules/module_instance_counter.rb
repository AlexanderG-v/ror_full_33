# frozen_string_literal: true

module InstanceCounter
  def self.included(base)
    base.extend ClassMethods
    base.include InstanceMethods
  end

  # содержит метод который возвращает кол-во экземпляров класса
  module ClassMethods
    attr_accessor :instances_counter

    def instances
      @instances_counter # инстанс переменная уровня класса
    end
  end

  # содержит защищенный метод, который увеличивает кол-во экземпляров класса
  module InstanceMethods
    protected

    def register_instance
      self.class.instances_counter ||= 0
      self.class.instances_counter += 1
    end
  end
end
