import gleam/io
import gleam/iterator
import gleam/int.{sum}
import gleam/list
import gleam/result
import shellout.{arguments}
import gleam/string
import gleam/float.{ceiling, round}
import gleam/bool
import gleam/pair

type Arguments {
  Problem(problem: Int)
  ParseError
}

pub fn main() {
  let args = arguments()

  case parse_args(args) {
    Problem(problem) -> solve_problem(problem)
    ParseError -> ["Error parsing arguments:", .. args] |> string.join(" ")
  }
  |> io.println
}

fn parse_args(args: List(String)) -> Arguments {
  case args {
    ["--problem", problem] -> problem |> int.parse |> result.unwrap(-1) |> Problem
    _ -> ParseError
  }
}

fn solve_problem(problem: Int) -> String {
  case problem {
    1 -> problem1()
    2 -> problem2()
    3 -> problem3()
    _ -> ["Problem ", problem |> int.to_string, " not implemented."] |> string.concat
  }
}

fn problem1() -> String {
  iterator.range(0,999)
  |> iterator.filter(fn(num) { num % 3 == 0 || num % 5 == 0})
  |> iterator.to_list
  |> sum
  |> int.to_string
}

fn problem2() -> String {
  iterator.iterate(
    #(1,2,3,2),
    fn(state) {
      let #(_, second, third, acc) = state
      let fib_sum = second + third
      #(second, third, fib_sum, case fib_sum % 2 == 0 {
        True -> acc + fib_sum
        _ -> acc
      })
    }
  )
  |> iterator.take_while(fn(state) {
    let #(_, _, third, _) = state
    third < 4_000_000
  })
  |> iterator.map(fn(state) {
    let #(_,_,_, acc) = state
    acc
  })
  |> iterator.to_list
  |> list.last
  |> result.unwrap(0)
  |> int.to_string
}

fn is_prime(num: Int) -> Bool {
  // We can optimize to only check primes in [2, ceil(sqrt(num))]
  assert Ok(sqrt_num) = num |> int.square_root
  let divides_num = fn(divisor) { num % divisor == 0 }

  iterator.range(2, sqrt_num |> ceiling |> round)
  |> iterator.any(divides_num)
  |> bool.negate
}

fn problem3() -> String {
  let target = 600851475143

  let increment = fn(tup: #(Int, Int)) {
    let inc = {tup |> pair.first } + 1
    #(inc, target/inc)
  }

  // Can optimize further: only need to check for the first
  // (lhs, rhs) where lhs | target and is_prime(rhs)
  // Can also construct sieve as we're going...
  iterator.iterate(#(3, target/3), increment)
  |> iterator.filter(fn(tup) {
    target % { tup |> pair.first } == 0
  })
  |> iterator.take_while(fn(tup) { 
    let #(first, second) = tup
    first <= second
  })
  |> iterator.map(fn(tup) {
    [tup |> pair.first, tup |> pair.second]
    |> iterator.from_list
  })
  |> iterator.flatten
  |> iterator.filter(is_prime)
  |> iterator.fold(-1, int.max)
  |> int.to_string
}
