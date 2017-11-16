# -*- coding: utf-8 -*- #

module Rouge
  module Lexers
    class IPL < RegexLexer
      title "IPL"
      desc 'Imandra protocol language (https://docs.imandra.ai/ipl/)'
      tag 'ipl'
      filenames '*.ipl', '*.ipld'
      mimetypes 'text/x-ipl'

      keywords = Set.new %w(
          VerificationPacks action alias assignFrom assignable case
          datatype declare default description enum events extend false
          focusOn ign ignored imandramarkets import in interLibraryCheck internal
          invalid invalidfield let library libraryMarker m message missingfield name
          opt optional outbound overloadFunction precision present r receive record
          reject repeating req require return scenario send testfile toFloat
          toInt true truncate unique valid validate when with
        )
      keyopts = Set.new %w(
          != && \( \) * + , - ==> : ; < == <= >= = > } ? [ ] { } ! / \|\|
        )
      word_operators = Set.new %w(None Some Case if then else)
      operators = %r([!*+<=>\-\/]+)
      primitives = Set.new %w(int float bool string)
      infix_syms = %r([*+<=>\-\/])
      prefix_syms = %r([!])

      state :root do
        rule %r(\s+), Text
        rule %r(false|true|it|this|\(\)|\[\]), Name::Builtin::Pseudo
        rule %r(//.*?$), Comment::Single
        rule %r(/\*), Comment, :comment
        rule %r(#{ keywords.to_a.join('|') }), Keyword
        rule %r(#{ keyopts }), Operator
        rule %r((#{ infix_syms }|#{ prefix_syms })?#{ operators }), Operator
        rule %r(\b(#{ word_operators.to_a.join('|') })\b), Operator::Word
        rule %r(\b(#{ primitives.to_a.join('|') })\b), Keyword::Type
        rule %r([\.]?([a-zA-Z_$][a-zA-Z\d_$]*\.)*[a-zA-Z_$][a-zA-Z\d_$]*), Name
        rule %r(-?\d[\d_]*(.[\d_]*)*), Num::Float
        rule %r(\d[\d_]*), Num::Integer
        rule %r("), Str::Double, :string
      end

      state :comment do
        rule( %r(/\*)) { token Comment; push }
        rule %r(\*/), Comment, :pop!
      end

      state :string do
        rule %r([^\\"]+), Str::Double
        mixin :escape_sequence
        rule %r(\\\n), Str::Double
        rule %r("), Str::Double, :pop!
      end

      state :escape_sequence do
        rule %r(\\[\\"'ntbr]), Str::Escape
        rule %r(\\\d{3}), Str::Escape
        rule %r(\\x\h{2}), Str::Escape
      end
    end
  end
end
