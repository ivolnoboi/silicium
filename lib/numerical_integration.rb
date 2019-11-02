module Silicium
  class IntegralDoesntExistError < RuntimeError; end
  
  class NumberofIterOutofRangeError < RuntimeError; end
    
  ##
  # A class providing numerical integration methods
  class NumericalIntegration

    # Computes integral from +a+ to +b+ of +block+ with accuracy +eps+
    def self.three_eights_integration(a, b, eps = 0.0001, &block)
      wrapper_method([a, b], eps, :three_eights_integration_n, &block)
    end

    # Computes integral from +a+ to +b+ of +block+ with +n+ segmentations
    def self.three_eights_integration_n(a, b, n, &block)
      dx = (b - a) / n.to_f
      result = 0
      x = a
      n.times do
        result +=
          (block.call(x) + 3 * block.call((2 * x + x + dx) / 3.0) +
              3 * block.call((x + 2 * (x + dx)) / 3.0) + block.call(x + dx)) / 8.0 * dx
        x += dx
      end
      result
    end


    # Simpson integration with a segment
    def self.simpson_integration_with_a_segment(a, b, n, &block)
      dx = (b - a) / n.to_f
      result = 0
      i = 0
      while i < n
        result += (block.call(a + i * dx) + 4 * block.call(((a + i * dx) +
            (a + (i + 1) * dx)) / 2.0) + block.call(a + (i + 1) * dx)) / 6.0 * dx
        i += 1
      end
      result
    end

    # Simpson integration with specified accuracy
    def self.simpson_integration(a, b, eps = 0.0001, &block)
      wrapper_method([a, b], eps, :simpson_integration_with_a_segment, &block)
    end

    # Left Rectangle Method and Right Rectangle Method
    def self.left_rect_integration(left_p, right_p, eps = 0.0001, &block)
      splits = 1
      res1 = left_rect_integration_n(left_p, right_p, 1, &block)
      res2 = left_rect_integration_n(left_p, right_p, 5, &block)
      while (res1 - res2).abs > eps
        res1 = left_rect_integration_n(left_p, right_p, splits, &block)
        splits *= 5
        res2 = left_rect_integration_n(left_p, right_p, splits, &block)
      end
      (res1 + res2) / 2.0
    end

    # Left Rectangle Auxiliary Method and Right Rectangle Auxiliary Method
    def self.left_rect_integration_n(left_p, right_p, splits, &block)
      dx = (right_p - left_p) / splits.to_f
      result = 0
      i = 0
      while i < splits
        result += block.call(left_p + i * dx)
        i += 1
      end
      result * dx
    end


    # Middle Rectangles Method with a segment
    def self.middle_rectangles_with_a_segment(a, b, n, &block)
      dx = (b - a) / n.to_f
      result = 0
      i = 0
      n.times do
        result += block.call(a + dx * (i + 1 / 2)) * dx
        i += 1
      end
      result
    end

    # Middle Rectangles Method  with specified accuracy
    def self.middle_rectangles(a, b, eps = 0.0001, &block)
      wrapper_method([a, b], eps, :middle_rectangles_with_a_segment, &block)
    end


    # Trapezoid Method with a segment
    def self.trapezoid_with_a_segment(a, b, n, &block)
      dx = (b - a) / n.to_f
      result = 0
      i = 1
      (n - 1).times do
        result += block.call(a + dx * i)
        i += 1
      end
      result += (block.call(a) + block.call(b)) / 2.0
      result * dx
    end

    # Trapezoid Method with specified accuracy
    def self.trapezoid(a, b, eps = 0.0001, &block)
      wrapper_method([a, b], eps, :trapezoid_with_a_segment ,&block)
    end

    private

    ##
    # Wrapper method for num_integratons methods
    # @param [Array] a_b integration range
    # @param [Numeric] eps
    # @param [Proc] proc - integration Proc
    # @param [Block] block - integrated function as Block
    def self.wrapper_method(a_b, eps, method_name, &block)
      n = 1
      max_it = 10_000
      begin
        begin
          result = send(method_name, a_b[0], a_b[1], n, &block)
          check_value(result)
          n *= 5
          raise NumberofIterOutofRangeError if n > max_it
          result1 = send(method_name, a_b[0], a_b[1], n, &block)
          check_value(result1)
        end until (result - result1).abs < eps
          
      rescue Math::DomainError
        raise IntegralDoesntExistError, 'Domain error in math function'
      rescue ZeroDivisionError
        raise IntegralDoesntExistError, 'Divide by zero'
      end
      (result + result1) / 2.0
    end

    def self.check_value(value)
      if value.nan?
        raise IntegralDoesntExistError, 'We have not-a-number result :('
      end
      if value == Float::INFINITY
        raise IntegralDoesntExistError, 'We have infinity :('
      end
    end
  end
end


