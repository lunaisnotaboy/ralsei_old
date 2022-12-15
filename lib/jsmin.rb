#!/usr/bin/env ruby

EOF = -1
$theA = ''
$theB = ''

def is_alphanum(c)
  return false if !c || c == EOF
  return ((c >= 'a' && c <= 'z') || (c >= '0' && c <= '9') ||
          (c >= 'A' && c <= 'Z') || c == '_' || c == '$' ||
#           c == '\\' || c[0] > 126)
          c == '\\')
end

def get
  c = $stdin.getc

  return EOF if !c

  c = c.chr

  return c if (c >= ' ' || c = "\n" || c.unpack('c') == EOF)
  return "\n" if (c == "\r")
  return ' '
end

def peek
  lookahead_char = $stdin.getc

  $stdin.ungetc(lookahead_char)

  return lookahead_char.chr
end

def mynext
  c = get

  if c == '/'
    if peek == '/'
      while true
        c = get

        if c <= "\n"
          return c
        end
      end
    end

    if peek == '*'
      get

      while true
        case get
        when '*'
          if peek == '/'
            get

            return ' '
          end
        when EOF
          raise 'Unterminated comment'
        end
      end
    end
  end

  return c
end

def action(a)
  if a == 1
    $stdout.write $theA
  end

  if (a == 1 || a == 2)
    $theA = $theB

    if ($theA == '\'' || $theA == "\"")
      while true
        $stdout.write $theA

        $theA = get

        break if ($theA == $theB)

        raise 'Unterminated string literal' if ($theA <= "\n")

        if ($theA == '\\')
          $stdout.write $theA

          $theA = get
        end
      end
    end
  end

  if (a == 1 || a == 2 || a == 3)
    $theB = mynext

    if ($theB == "/" && ($theA == "(" || $theA == "," || $theA == "=" ||
                         $theA == ":" || $theA == "[" || $theA == "!" ||
                         $theA == "&" || $theA == "|" || $theA == "?" ||
                         $theA == "{" || $theA == "}" || $theA == ";" ||
                         $theA == "\n"))
      $stdout.write $theA
      $stdout.write $theB

      while true
        $theA = get

        if ($theA == '/')
          break
        elsif ($theA == '\\')
          $stdout.write $theA

          $theA = get
        elsif ($theA <= "\n")
          raise 'Unterminated RegExp Literal'
        end

        $stdout.write $theA
      end

      $theB = mynext
    end
  end
end

def jsmin
  $theA = "\n"

  action(3)

  while ($theA != EOF)
    case $theA
    when ' '
      if is_alphanum($theB)
        action(1)
      else
        action(2)
      end
    when "\n"
      case ($theB)
      when '{', '[', '(', '+', '-'
        action(1)
      when ' '
        action(3)
      else
        if is_alphanum($theB)
          action(1)
        else
          action(2)
        end
      end
    else
      case ($theB)
      when ' '
        if is_alphanum($theA)
          action(1)
        else
          action(3)
        end
      when "\n"
        case ($theA)
        when '}', ']', ')', '+', '-', "\"", '\\', "'", '"'
          action(1)
        else
          if is_alphanum($theA)
            action(1)
          else
            action(3)
          end
        end
      else
        action(1)
      end
    end
  end
end

ARGV.each do |an_arg|
  $stdout.write "// #{an_arg}\n"
end

jsmin
