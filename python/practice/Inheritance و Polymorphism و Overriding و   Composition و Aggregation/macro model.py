import logging
logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")


# ---------- سلسله‌مراتب Exception (تمرین ۷) ----------
class MacroModelError(Exception):
    pass

class InvalidParameterError(MacroModelError):
    pass


# ---------- کلاس پایه‌ی انتزاعی ----------
class MacroModel:
    def __init__(self, name, **params):
        self.name = name
        self.params = params   # *kwargs برای پارامترهای متغیر هر مدل (تمرین ۲)

    def validate(self):
        """هر مدل باید پارامترهای خودش را چک کند"""
        raise NotImplementedError

    def run(self):
        """هر مدل باید منطق محاسباتی خودش را اجرا کند"""
        raise NotImplementedError

    def report(self):
        """متد مشترک که override نمی‌شود؛ روی نتیجه‌ی run() کار می‌کند"""
        self.validate()
        result = self.run()
        return f"[{self.name}] result: {result:.4f}"


# ---------- مدل ۱: رشد سولو (Solow Growth Model) ----------
class SolowGrowthModel(MacroModel):
    def __init__(self, **params):
        super().__init__("Solo Growth Model", **params)

    def _cobb_douglas(self, K, L, A, alpha):
        """تابع تولید Cobb-Douglas: Y = A * K^alpha * L^(1-alpha)"""
        return A * (K ** alpha) * (L ** (1 - alpha))

    def validate(self):
        alpha = self.params.get("alpha", 0.3)
        if not (0 < alpha < 1):
            raise InvalidParameterError("alpha must be between 0 and 1")

    def run(self):
        K = self.params.get("K", 100)
        L = self.params.get("L", 50)
        A = self.params.get("A", 1.5)
        alpha = self.params.get("alpha", 0.3)
        return self._cobb_douglas(K, L, A, alpha)


# ---------- مدل ۲: درآمد کینزی (Keynesian Income Model) ----------
class KeynesianIncomeModel(MacroModel):
    def __init__(self, **params):
        super().__init__("Keynesian income model", **params)

    def _consumption(self, Y, c0, mpc):
        """تابع مصرف: C = c0 + mpc * Y"""
        return c0 + mpc * Y

    def validate(self):
        mpc = self.params.get("mpc", 0.8)
        if not (0 <= mpc < 1):
            raise InvalidParameterError("MPC (marginal propensity to consume) must be between 0 and 1.")

    def run(self):
        c0 = self.params.get("c0", 200)
        mpc = self.params.get("mpc", 0.8)
        I = self.params.get("I", 300)
        G = self.params.get("G", 250)
        # حل معادله‌ی تعادلی: Y = C + I + G = c0 + mpc*Y + I + G
        Y_equilibrium = (c0 + I + G) / (1 - mpc)
        return Y_equilibrium


# ---------- مدل ۳: نظریه‌ی مقداری پول (Quantity Theory of Money) ----------
class QuantityTheoryModel(MacroModel):
    def __init__(self, **params):
        super().__init__("Quantity theory of money", **params)

    def _price_level(self, M, V, Y):
        """MV = PY  =>  P = MV / Y"""
        if Y == 0:
            raise InvalidParameterError("Production (Y) cannot be zero.")
        return (M * V) / Y

    def validate(self):
        Y = self.params.get("Y", 1000)
        if Y <= 0:
            raise InvalidParameterError("Y must be positive.")

    def run(self):
        M = self.params.get("M", 500)
        V = self.params.get("V", 4)
        Y = self.params.get("Y", 1000)
        return self._price_level(M, V, Y)


# ---------- اجرای پلی‌مورفیک روی همه‌ی مدل‌ها ----------
def run_all_models(models):
    for model in models:
        try:
            print(model.report())
        except MacroModelError as e:
            logging.exception(f"Error in {model.name}")


if __name__ == "__main__":
    models = [
        SolowGrowthModel(K=200, L=80, A=2.0, alpha=0.35),
        KeynesianIncomeModel(c0=250, mpc=0.75, I=400, G=300),
        QuantityTheoryModel(M=600, V=5, Y=1200),
        SolowGrowthModel(alpha=1.2),   # عمداً نامعتبر تا Exception را تست کنیم
    ]
    run_all_models(models)