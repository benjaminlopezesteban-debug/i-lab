def divide(a, b):
    if b == 0:
        raise ValueError("No se puede dividir por cero")
    return a / b

def average(nums):
    return sum(nums) / len(nums)

def test_divide():
    # Caso normal
    assert divide(10, 2) == 5.0
    
    # Caso división por cero
    try:
        divide(10, 0)
        assert False, "Debería haber lanzado una excepción"
    except ValueError as e:
        assert str(e) == "No se puede dividir por cero"

if __name__ == "__main__":
    test_divide()
    print(divide(10, 2))
    print(average([1, 2, 3, 4, 5]))
