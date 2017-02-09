# -*- coding: utf-8 -*- #

module Rouge
  module Lexers
    class GraphQL < RegexLexer
      title "GraphQL"
      desc "The GraphQL query language (http://graphql.org/)"
      tag 'graphql'
      aliases 'graphql'
      filenames '*.graphql'
      mimetypes 'application/graphql'

      name = /[_A-Za-z][_0-9A-Za-z]*/

      state :definition_start do
        rule(/\s+/m, Text::Whitespace)
        rule(name, Name::Entity, :pop!)
        mixin :root
      end

      state :selection_set_start do
        rule(/\s+/m, Text::Whitespace)

        rule %r(
          ([_A-Za-z][_0-9A-Za-z]*)
          (:)
          (\s*)
          ([_A-Za-z][_0-9A-Za-z]*)
        )x do
          groups Name::Entity, Punctuation, Text::Whitespace, Name::Other
        end

        mixin :root
      end

      state :type_condition do
        rule(/\s+/m, Text::Whitespace)
        rule(name, Name::Class, :pop!)
      end

      state :fragment_start do
        rule(name, Name::Entity)
        mixin :root
      end

      state :spread_start do
        mixin :root
        rule(name, Name::Attribute)
      end

      state :argument_start do
        rule(/\{|\}/, Punctuation)
        rule(/=/, Operator)

        rule %r(
          ([_A-Za-z][_0-9A-Za-z]*)
          (:)
          (\s*)
        )x do
          groups Name::Attribute, Punctuation, Text::Whitespace
        end

        rule(/\s+/m, Text::Whitespace)
        rule(/"/, Str::Double, :string)
        rule(/(?:true|false|null)\b/, Keyword::Constant)
        rule(/-?(?:0|[1-9]\d*)\.\d+(?:e[+-]?\d+)?/i, Num::Float)
        rule(/-?(?:0|[1-9]\d*)(?:e[+-]?\d+)?/i, Num::Integer)
        rule(/!/, Operator)
        rule(/\$\w+/, Name::Variable)
        rule(/\b[A-Z0-9]+\b/, Name::Constant)

        rule(name, Name::Class)
        rule(/[:|,]/, Punctuation)
        rule(/\)/, Punctuation, :pop!)
      end

      state :root do
        rule(/\s+/m, Text::Whitespace)
        rule(%r(#.*?$), Comment::Single)
        rule(/"/, Str::Double, :string)
        rule(/(?:true|false|null)\b/, Keyword::Constant)
        rule(/^\[|\]|:|,/, Punctuation)
        rule(/-?(?:0|[1-9]\d*)\.\d+(?:e[+-]?\d+)?/i, Num::Float)
        rule(/-?(?:0|[1-9]\d*)(?:e[+-]?\d+)?/i, Num::Integer)
        rule(/!/, Operator)
        rule(/\$\w+/, Name::Variable)
        rule(/\b[A-Z0-9]+\b/, Name::Constant)

        rule(/\bquery|mutation|fragment\b/, Keyword::Reserved, :definition_start)
        rule(/\bon\b/, Keyword::Reserved, :type_condition)

        rule(/\(/, Punctuation, :argument_start)
        rule(/\{|\}/, Punctuation, :selection_set_start)
        rule(/\.\.\./, Operator, :spread_start)

        rule(name, Name::Other)
      end

      state :string do
        rule(/[^\\"]+/, Str::Double)
        rule(/\\./, Str::Escape)
        rule(/"/, Str::Double, :pop!)
      end
    end
  end
end
