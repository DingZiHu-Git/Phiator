extends Node

func linear(t: float) -> float:
	return t
func in_quad(t: float) -> float:
	return t * t
func out_quad(t: float) -> float:
	return -t * (t - 2)
func in_out_quad(t: float) -> float:
	t *= 2
	if t < 1:
		return 0.5 * t * t
	return -0.5 * ((t - 1) * (t - 3) - 1)
func out_in_quad(t: float) -> float:
	if t < 0.5:
		return out_quad(t * 2) / 2
	return in_quad((t * 2) - 1) / 2 + 0.5
func in_cubic(t: float) -> float:
	return t * t * t
func out_cubic(t: float) -> float:
	t -= 1
	return t * t * t + 1
func in_out_cubic(t: float) -> float:
	t *= 2
	if t < 1:
		return 0.5 * t * t * t
	t -= 2
	return 0.5 * (t * t * t + 2)
func out_in_cubic(t: float) -> float:
	if t < 0.5:
		return out_cubic(t * 2) / 2
	return in_cubic((t * 2) - 1) / 2 + 0.5
func in_quart(t: float) -> float:
	return t * t * t * t
func out_quart(t: float) -> float:
	t -= 1
	return -(t * t * t * t - 1)
func in_out_quart(t: float) -> float:
	t *= 2
	if t < 1:
		return 0.5 * t * t * t * t
	t -= 2
	return -0.5 * (t * t * t * t - 2)
func out_in_quart(t: float) -> float:
	if t < 0.5:
		return out_quart(t * 2) / 2
	return in_quart((t * 2) - 1) / 2 + 0.5
func in_quint(t: float) -> float:
	return t * t * t * t * t
func out_quint(t: float) -> float:
	t -= 1
	return t * t * t * t * t + 1
func in_out_quint(t: float) -> float:
	t *= 2
	if t < 1:
		return 0.5 * t * t * t * t * t
	t -= 2
	return 0.5 * (t * t * t * t * t + 2)
func out_in_quint(t: float) -> float:
	if t < 0.5:
		return out_quint(t * 2) / 2
	return in_quint((t * 2) - 1) / 2 + 0.5
func in_sine(t: float) -> float:
	return -cos(t * PI / 2) + 1
func out_sine(t: float) -> float:
	return sin(t * PI / 2)
func in_out_sine(t: float) -> float:
	return -0.5 * (cos(PI * t) - 1)
func out_in_sine(t: float) -> float:
	if t < 0.5:
		return out_sine(t * 2) / 2
	return in_sine((t * 2) - 1) / 2 + 0.5
func in_expo(t: float) -> float:
	if t == 0:
		return 0
	else:
		return pow(2, 10 * (t - 1))
func out_expo(t: float) -> float:
	if t == 1:
		return 1
	else:
		return -pow(2, -10 * t) + 1
func in_out_expo(t: float) -> float:
	if t == 0:
		return 0
	if t == 1:
		return 1
	t *= 2
	if t < 1:
		return 0.5 * pow(2, 10 * (t - 1))
	return 0.5 * (-pow(2, -10 * (t - 1)) + 2)
func out_in_expo(t: float) -> float:
	if t < 0.5:
		return out_expo(t * 2) / 2
	return in_expo((t * 2) - 1) / 2 + 0.5
func in_circ(t: float) -> float:
	return -(sqrt(1 - t * t) - 1)
func out_circ(t: float) -> float:
	t -= 1
	return sqrt(1 - t * t)
func in_out_circ(t: float) -> float:
	t *= 2
	if t < 1:
		return -0.5 * (sqrt(1 - t * t) - 1)
	t -= 2
	return 0.5 * (sqrt(1 - t * t) + 1)
func out_in_circ(t: float) -> float:
	if t < 0.5:
		return out_circ(t * 2) / 2
	return in_circ((t * 2) - 1) / 2 + 0.5
func in_back(t: float) -> float:
	var s: float = 1.70158
	return t * t * ((s + 1) * t - s)
func out_back(t: float) -> float:
	var s: float = 1.70158
	t -= 1
	return t * t * ((s + 1) * t + s) + 1
func in_out_back(t: float) -> float:
	var s: float = 1.70158 * 1.525
	t *= 2
	if t < 1:
		return 0.5 * (t * t * ((s + 1) * t - s))
	t -= 2
	return 0.5 * (t * t * ((s + 1) * t + s) + 1)
func out_in_back(t: float) -> float:
	if t < 0.5:
		return out_back(t * 2) / 2
	return in_back((t * 2) - 1) / 2 + 0.5
func in_elastic(t: float) -> float:
	if t == 0:
		return 0
	if t == 1:
		return 1
	var p: float = 0.3
	var s: float = p / 4
	t -= 1
	return -(pow(2, 10 * t) * sin((t - s) * (2 * PI) / p))
func out_elastic(t: float) -> float:
	if t == 0:
		return 0
	if t == 1:
		return 1
	var p: float = 0.3
	var s: float = p / 4
	return pow(2, -10 * t) * sin((t - s) * (2 * PI) / p) + 1
func in_out_elastic(t: float) -> float:
	if t == 0:
		return 0
	t *= 2
	if t == 2:
		return 1
	var p: float = 0.3 * 1.5
	var s: float = p / 4
	if t < 1:
		t -= 1
		return -0.5 * (pow(2, 10 * t) * sin((t - s) * (2 * PI) / p))
	t -= 1
	return 0.5 * pow(2, -10 * t) * sin((t - s) * (2 * PI) / p) + 1
func out_in_elastic(t: float) -> float:
	if t < 0.5:
		return out_elastic(t * 2) / 2
	return in_elastic((t * 2) - 1) / 2 + 0.5
func out_bounce(t: float) -> float:
	if t < (1 / 2.75):
		return 7.5625 * t * t
	elif t < (2 / 2.75):
		t -= (1.5 / 2.75)
		return 7.5625 * t * t + 0.75
	elif t < (2.5 / 2.75):
		t -= (2.25 / 2.75)
		return 7.5625 * t * t + 0.9375
	else:
		t -= (2.625 / 2.75)
		return 7.5625 * t * t + 0.984375
func in_bounce(t: float) -> float:
	return 1 - out_bounce(1 - t)
func in_out_bounce(t: float) -> float:
	if t < 0.5:
		return in_bounce(t * 2) / 2
	return out_bounce(t * 2 - 1) / 2 + 0.5
func out_in_bounce(t: float) -> float:
	if t < 0.5:
		return out_bounce(t * 2) / 2
	return in_bounce((t * 2) - 1) / 2 + 0.5
