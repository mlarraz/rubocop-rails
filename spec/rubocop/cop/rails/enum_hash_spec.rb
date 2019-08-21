# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::EnumHash do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  context 'when array syntax is used' do
    context 'with %i[] syntax' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          enum status: %i[active archived]
                       ^^^^^^^^^^^^^^^^^^^ Enum defined as an array found in `status` enum declaration. Use hash syntax instead.
        RUBY
      end
    end

    context 'with %w[] syntax' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          enum status: %w[active archived]
                       ^^^^^^^^^^^^^^^^^^^ Enum defined as an array found in `status` enum declaration. Use hash syntax instead.
        RUBY
      end
    end

    context 'with %i() syntax' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          enum status: %i(active archived)
                       ^^^^^^^^^^^^^^^^^^^ Enum defined as an array found in `status` enum declaration. Use hash syntax instead.
        RUBY
      end
    end

    context 'with %w() syntax' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          enum status: %w(active archived)
                       ^^^^^^^^^^^^^^^^^^^ Enum defined as an array found in `status` enum declaration. Use hash syntax instead.
        RUBY
      end
    end

    context 'with [] syntax' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          enum status: [:active, :archived]
                       ^^^^^^^^^^^^^^^^^^^^ Enum defined as an array found in `status` enum declaration. Use hash syntax instead.
        RUBY
      end
    end

    context 'when the enum name is a string' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          enum "status" => %i[active archived]
                           ^^^^^^^^^^^^^^^^^^^ Enum defined as an array found in `status` enum declaration. Use hash syntax instead.
        RUBY
      end
    end

    context 'when the enum name is not a literal' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          enum KEY => %i[active archived]
                      ^^^^^^^^^^^^^^^^^^^ Enum defined as an array found in `KEY` enum declaration. Use hash syntax instead.
        RUBY
      end
    end

    context 'with multiple enum definition for a `enum` method call' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          enum status: %i[active archived],
                       ^^^^^^^^^^^^^^^^^^^ Enum defined as an array found in `status` enum declaration. Use hash syntax instead.
               role: %i[owner member guest]
                     ^^^^^^^^^^^^^^^^^^^^^^ Enum defined as an array found in `role` enum declaration. Use hash syntax instead.
        RUBY
      end
    end

    it 'autocorrects' do
      expect_offense(<<~RUBY)
        enum status: [:old, :"very active", "is archived", 42]
                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Enum defined as an array found in `status` enum declaration. Use hash syntax instead.
      RUBY

      expect_correction(<<~RUBY)
        enum status: {:old=>0, :"very active"=>1, "is archived"=>2, 42=>3}
      RUBY
    end

    it 'autocorrects nested constants' do
      expect_offense(<<~RUBY)
        STATUS::OLD = :old
        STATUS::ACTIVE = :active
        enum status: [STATUS::OLD, STATUS::ACTIVE]
                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Enum defined as an array found in `status` enum declaration. Use hash syntax instead.
      RUBY

      expect_correction(<<~RUBY)
        STATUS::OLD = :old
        STATUS::ACTIVE = :active
        enum status: {STATUS::OLD=>0, STATUS::ACTIVE=>1}
      RUBY
    end
  end

  context 'when hash syntax is used' do
    it 'does not register an offense' do
      expect_no_offenses('enum status: { active: 0, archived: 1 }')
    end
  end
end
