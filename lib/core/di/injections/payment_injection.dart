import 'package:get_it/get_it.dart';
import '../../../features/payment/presentation/cubit/payment_cubit.dart';

void registerPaymentDependencies(GetIt sl) {
  // Cubit - Factory (new instance each time)
  sl.registerFactory<PaymentCubit>(() => PaymentCubit());
}
