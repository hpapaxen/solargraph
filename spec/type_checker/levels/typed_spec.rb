describe Solargraph::TypeChecker do
  context 'typed level' do
    def type_checker(code)
      Solargraph::TypeChecker.load_string(code, 'test.rb', :typed)
    end

    it 'reports mismatched types for empty methods' do
      checker = type_checker(%(
        class Foo
          # @return [String]
          def bar; end
        end
      ))
      expect(checker.problems).to be_one
      expect(checker.problems.first.message).to include('does not match')
    end

    it 'ignores attributes with return tags' do
      checker = type_checker(%(
        class Foo
          # @return [Integer]
          attr_reader :bar
        end
      ))
      expect(checker.problems).to be_empty
    end

    it 'reports mismatched return tags' do
      checker = type_checker(%(
        class Foo
          # @return [Integer]
          def bar
            'string'
          end
        end
      ))
      expect(checker.problems).to be_one
      expect(checker.problems.first.message).to include('does not match')
    end

    it 'reports mismatched inherited return tags' do
      checker = type_checker(%(
        class Sup
          # @return [String]
          def name
            'sup'
          end
        end

        class Sub < Sup
          def name
            100
          end
        end
      ))
      expect(checker.problems).to be_one
      expect(checker.problems.first.message).to include('does not match')
    end

    it 'reports mismatched return tags from mixins' do
      checker = type_checker(%(
        module Mixin
          # @return [String]
          def name
            'sup'
          end
        end

        class Thing
          include Mixin

          def name
            100
          end
        end
      ))
      expect(checker.problems).to be_one
      expect(checker.problems.first.message).to include('does not match')
    end

    it 'validates boolean return types' do
      checker = type_checker(%(
        class Foo
          # @return [Boolean]
          def bar
            1 == 2
          end
        end
      ))
      expect(checker.problems).to be_empty
    end

    it 'reports mismatched type tags' do
      checker = type_checker(%(
        # @type [Integer]
        x = 'string'
      ))
      expect(checker.problems).to be_one
      expect(checker.problems.first.message).to include('does not match')
    end

    it 'reports mismatched boolean return types' do
      checker = type_checker(%(
        class Foo
          # @return [Boolean]
          def bar
            'true'
          end
        end
      ))
      expect(checker.problems).to be_one
      expect(checker.problems.first.message).to include('does not match')
    end
  end
end