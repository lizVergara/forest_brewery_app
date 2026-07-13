import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/error/app_exception.dart';
import '../../../domain/repositories/brewery_repository.dart';
import 'brewery_detail_state.dart';

@injectable
class BreweryDetailCubit extends Cubit<BreweryDetailState> {
  final BreweryRepository _repository;

  BreweryDetailCubit(this._repository) : super(const BreweryDetailInitial());

  Future<void> loadBrewery(String id) async {
    emit(const BreweryDetailLoading());

    try {
      final brewery = await _repository.getBreweryById(id);

      emit(BreweryDetailSuccess(brewery));
    } on AppException catch (error) {
      emit(BreweryDetailError(error.message));
    } catch (_) {
      emit(const BreweryDetailError('Something went wrong. Please try again.'));
    }
  }
}
