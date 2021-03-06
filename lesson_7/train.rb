# frozen_string_literal: true

require_relative 'modules/module_instance_counter'
require_relative 'modules/module_manufacturer'
require_relative 'modules/module_valid'

class Train
  NUMBER_FORMATE = /^[\w\d]{3}.[\w\d]{2}$/i.freeze
  # - при создании экземпляра класса указывается номер (произвольная строка) и тип (грузовой, пассажирский)
  include Manufacturer
  include InstanceCounter
  include Valid

  attr_accessor :wagons
  attr_reader :current_speed, :number, :current_station

  @@trains = {} #
  # метод принимает номер поезда и возвращает объект по номеру
  def self.find(number)
    @@trains[number]
  end

  def initialize(number)
    @number = number
    @wagons = []
    @current_speed = 0
    @@trains[number] = self
    validate!
    register_instance
  end

  # - набирает скорость
  def speed_up(speed)
    self.current_speed += speed
  end

  # - тормозит (сбрасывает скорость до нуля)
  def stop
    self.current_speed = 0
  end

  # - прицепляет вагоны(по одному вагону за операцию) при условии, что поезд не движется
  def add_wagons(wagon)
    wagons << wagon if wagon.type_wagon == @type_train && self.current_speed.zero?
  end

  # - отцепляет вагоны по типу (грузовой/пассажирский (по одному вагону за операцию) при условии, что поезд не движется
  def remove_wagons(wagon)
    wagons.delete(wagon) if wagon.type_wagon == @type_train && self.current_speed.zero?
  end

  # - принимает маршрут следования (экземпляр класса Route)
  # - при назначении маршрута поезду, поезд автоматически помещается на первую станцию в маршруте
  def add_route(route)
    @route = route
    @current_station = @route.stations[0]
    @route.add_train(self)
  end

  # - возвращает предыдущую станцию, на основе маршрута
  def previous_station
    @route.stations[@route.stations.index(@current_station) - 1] if @current_station != @route.stations.first
  end

  # - возвращает следующую станцию, на основе маршрута
  def next_station
    @route.stations[@route.stations.index(@current_station) + 1] if @current_station != @route.stations.last
  end

  # - перемещение вперед между станциями, но только на одну станцию за раз
  def go_forward
    return unless next_station

    @current_station.departure(self)
    @current_station = next_station
    @current_station.arrival(self)
  end

  # - перемещение назад между станциями, но только на одну станцию за раз
  def go_back
    return unless previous_station

    @current_station.departure(self)
    @current_station = previous_station
    @current_station.arrival(self)
  end
# проходит по массиву вагонов, передавая каждый объект в блок
  def all_wagons
    @wagons.each {|wagon| yield(wagon)}
  end

  protected

  # - проверка на наличие атрибутa и формат номера
  def validate!
    raise if number.nil?
    raise if number !~ NUMBER_FORMATE
  end
  # занечени current_speed устанавливается общедоступными методами

  private

  attr_writer :current_speed
end
