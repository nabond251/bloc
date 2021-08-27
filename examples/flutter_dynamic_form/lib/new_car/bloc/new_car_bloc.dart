import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_dynamic_form/new_car_repository.dart';

part 'new_car_event.dart';
part 'new_car_state.dart';

class NewCarBloc extends Bloc<NewCarEvent, NewCarState> {
  NewCarBloc({required NewCarRepository newCarRepository})
      : _newCarRepository = newCarRepository,
        super(const NewCarState.initial()) {
    on<NewCarEvent>(_onEvent, transform: enqueue());
  }

  final NewCarRepository _newCarRepository;

  void _onEvent(NewCarEvent event, Emitter<NewCarState> emit) {
    if (event is NewCarFormLoaded) return _onNewCarFormLoaded(event, emit);
    if (event is NewCarBrandChanged) return _onNewCarBrandChanged(event, emit);
    if (event is NewCarModelChanged) return _onNewCarModelChanged(event, emit);
    if (event is NewCarYearChanged) return _onNewCarYearChanged(event, emit);
  }

  void _onNewCarFormLoaded(
    NewCarFormLoaded event,
    Emitter<NewCarState> emit,
  ) async {
    emit(const NewCarState.brandsLoadInProgress());
    final brands = await _newCarRepository.fetchBrands();
    emit(NewCarState.brandsLoadSuccess(brands: brands));
  }

  void _onNewCarBrandChanged(
    NewCarBrandChanged event,
    Emitter<NewCarState> emit,
  ) async {
    emit(NewCarState.modelsLoadInProgress(
      brands: state.brands,
      brand: event.brand,
    ));
    final models = await _newCarRepository.fetchModels(brand: event.brand);
    emit(NewCarState.modelsLoadSuccess(
      brands: state.brands,
      brand: event.brand,
      models: models,
    ));
  }

  void _onNewCarModelChanged(
    NewCarModelChanged event,
    Emitter<NewCarState> emit,
  ) async {
    emit(NewCarState.yearsLoadInProgress(
      brands: state.brands,
      brand: state.brand,
      models: state.models,
      model: event.model,
    ));
    final years = await _newCarRepository.fetchYears(
      brand: state.brand,
      model: event.model,
    );
    emit(NewCarState.yearsLoadSuccess(
      brands: state.brands,
      brand: state.brand,
      models: state.models,
      model: event.model,
      years: years,
    ));
  }

  void _onNewCarYearChanged(
    NewCarYearChanged event,
    Emitter<NewCarState> emit,
  ) {
    emit(state.copyWith(year: event.year));
  }
}
