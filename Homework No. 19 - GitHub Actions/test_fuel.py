import pytest
from fuel import convert, gauge

def test_convert():
    with pytest.raises(ValueError):
        convert("two/three")
    with pytest.raises(ZeroDivisionError):
        convert("3/0")
    assert convert("1/4") == 25
    assert convert("4/4") == 100

def test_gauge():
    assert gauge(25) == "25%"
    assert gauge(1) == "E"
    assert gauge(99) == "F"
