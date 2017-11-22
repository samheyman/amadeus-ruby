require 'spec_helper'

RSpec.describe Amadeus::Client::Validator do
  describe 'Amadeus::Client.initialize' do
    before do
      @valid_params = {
        api_key: '1234',
        api_secret: '4546'
      }
    end

    it 'should create a new client with direct variables' do
      expect(Amadeus::Client.new(@valid_params)).to(
        be_instance_of(Amadeus::Client)
      )
    end

    it 'should create a new client with string-key variables' do
      params = {
        'api_key' => '1234',
        'api_secret' => '4546'
      }

      expect(Amadeus::Client.new(params)).to(
        be_instance_of(Amadeus::Client)
      )
    end

    it 'should create a new client with environment variables' do
      ENV['AMADEUS_API_KEY'] = '123'
      ENV['AMADEUS_API_SECRET'] = '234'

      expect(Amadeus::Client.new).to(
        be_instance_of(Amadeus::Client)
      )

      ENV.delete('AMADEUS_API_KEY')
      ENV.delete('AMADEUS_API_SECRET')
    end

    describe 'with missing parameters' do
      %i[api_key api_secret].each do |key|
        it "should refuse to create a new client without #{key}" do
          @valid_params.delete(key)
          expect{ Amadeus::Client.new(@valid_params) }.to(
            raise_error(ArgumentError)
          )
        end
      end
    end

    it 'should by default have a logger' do
      amadeus = Amadeus::Client.new(@valid_params)
      expect(amadeus.logger).to be_instance_of(Logger)
      expect(amadeus.logger.level).to eq(Logger::WARN)
    end

    [:logger, 'logger'].each do |key|
      it "should allow for setting a custom logger (#{key})" do
        logger = Logger.new(STDOUT)
        @valid_params[key] = logger
        amadeus = Amadeus::Client.new(@valid_params)
        expect(amadeus.logger).to equal(logger)
        expect(amadeus.logger.level).to eq(Logger::WARN)
      end
    end

    [:log_level, 'log_level'].each do |key|
      it "should allow for setting a custom log level (#{key})" do
        @valid_params[key] = Logger::FATAL
        amadeus = Amadeus::Client.new(@valid_params)
        expect(amadeus.logger.level).to eq(Logger::FATAL)
      end
    end

    it 'should warn when an unrecognized option is passed in' do
      logger = double('Logger')
      allow(logger).to receive(:level=).with(2)
      expect(logger).to receive(:warn).with('Amadeus::Client::Validator')

      @valid_params[:logger] = logger
      @valid_params[:foobar] = 'test'
      Amadeus::Client.new(@valid_params)
    end

    it 'should default to the test host' do
      amadeus = Amadeus::Client.new(@valid_params)
      expect(amadeus.host).to eq(Amadeus::Client::HOSTS[:test])
    end

    it 'should allow for setting a different hostname' do
      @valid_params[:hostname] = 'production'
      amadeus = Amadeus::Client.new(@valid_params)
      expect(amadeus.host).to eq(Amadeus::Client::HOSTS[:production])
    end

    it 'should allow for setting a full different host' do
      host = 'http://foo.bar.com/'
      @valid_params[:host] = host
      amadeus = Amadeus::Client.new(@valid_params)
      expect(amadeus.host).to eq(host)
    end
  end
end
