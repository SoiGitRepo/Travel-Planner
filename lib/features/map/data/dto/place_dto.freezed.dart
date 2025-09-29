// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'place_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LocationDto {
  double get lat;
  double get lng;

  /// Create a copy of LocationDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $LocationDtoCopyWith<LocationDto> get copyWith =>
      _$LocationDtoCopyWithImpl<LocationDto>(this as LocationDto, _$identity);

  /// Serializes this LocationDto to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is LocationDto &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.lng, lng) || other.lng == lng));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, lat, lng);

  @override
  String toString() {
    return 'LocationDto(lat: $lat, lng: $lng)';
  }
}

/// @nodoc
abstract mixin class $LocationDtoCopyWith<$Res> {
  factory $LocationDtoCopyWith(
          LocationDto value, $Res Function(LocationDto) _then) =
      _$LocationDtoCopyWithImpl;
  @useResult
  $Res call({double lat, double lng});
}

/// @nodoc
class _$LocationDtoCopyWithImpl<$Res> implements $LocationDtoCopyWith<$Res> {
  _$LocationDtoCopyWithImpl(this._self, this._then);

  final LocationDto _self;
  final $Res Function(LocationDto) _then;

  /// Create a copy of LocationDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lat = null,
    Object? lng = null,
  }) {
    return _then(_self.copyWith(
      lat: null == lat
          ? _self.lat
          : lat // ignore: cast_nullable_to_non_nullable
              as double,
      lng: null == lng
          ? _self.lng
          : lng // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// Adds pattern-matching-related methods to [LocationDto].
extension LocationDtoPatterns on LocationDto {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_LocationDto value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _LocationDto() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_LocationDto value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LocationDto():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_LocationDto value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LocationDto() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(double lat, double lng)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _LocationDto() when $default != null:
        return $default(_that.lat, _that.lng);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(double lat, double lng) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LocationDto():
        return $default(_that.lat, _that.lng);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(double lat, double lng)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LocationDto() when $default != null:
        return $default(_that.lat, _that.lng);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _LocationDto implements LocationDto {
  const _LocationDto({required this.lat, required this.lng});
  factory _LocationDto.fromJson(Map<String, dynamic> json) =>
      _$LocationDtoFromJson(json);

  @override
  final double lat;
  @override
  final double lng;

  /// Create a copy of LocationDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$LocationDtoCopyWith<_LocationDto> get copyWith =>
      __$LocationDtoCopyWithImpl<_LocationDto>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$LocationDtoToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _LocationDto &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.lng, lng) || other.lng == lng));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, lat, lng);

  @override
  String toString() {
    return 'LocationDto(lat: $lat, lng: $lng)';
  }
}

/// @nodoc
abstract mixin class _$LocationDtoCopyWith<$Res>
    implements $LocationDtoCopyWith<$Res> {
  factory _$LocationDtoCopyWith(
          _LocationDto value, $Res Function(_LocationDto) _then) =
      __$LocationDtoCopyWithImpl;
  @override
  @useResult
  $Res call({double lat, double lng});
}

/// @nodoc
class __$LocationDtoCopyWithImpl<$Res> implements _$LocationDtoCopyWith<$Res> {
  __$LocationDtoCopyWithImpl(this._self, this._then);

  final _LocationDto _self;
  final $Res Function(_LocationDto) _then;

  /// Create a copy of LocationDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? lat = null,
    Object? lng = null,
  }) {
    return _then(_LocationDto(
      lat: null == lat
          ? _self.lat
          : lat // ignore: cast_nullable_to_non_nullable
              as double,
      lng: null == lng
          ? _self.lng
          : lng // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
mixin _$GeometryDto {
  LocationDto get location;

  /// Create a copy of GeometryDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $GeometryDtoCopyWith<GeometryDto> get copyWith =>
      _$GeometryDtoCopyWithImpl<GeometryDto>(this as GeometryDto, _$identity);

  /// Serializes this GeometryDto to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is GeometryDto &&
            (identical(other.location, location) ||
                other.location == location));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, location);

  @override
  String toString() {
    return 'GeometryDto(location: $location)';
  }
}

/// @nodoc
abstract mixin class $GeometryDtoCopyWith<$Res> {
  factory $GeometryDtoCopyWith(
          GeometryDto value, $Res Function(GeometryDto) _then) =
      _$GeometryDtoCopyWithImpl;
  @useResult
  $Res call({LocationDto location});

  $LocationDtoCopyWith<$Res> get location;
}

/// @nodoc
class _$GeometryDtoCopyWithImpl<$Res> implements $GeometryDtoCopyWith<$Res> {
  _$GeometryDtoCopyWithImpl(this._self, this._then);

  final GeometryDto _self;
  final $Res Function(GeometryDto) _then;

  /// Create a copy of GeometryDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? location = null,
  }) {
    return _then(_self.copyWith(
      location: null == location
          ? _self.location
          : location // ignore: cast_nullable_to_non_nullable
              as LocationDto,
    ));
  }

  /// Create a copy of GeometryDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LocationDtoCopyWith<$Res> get location {
    return $LocationDtoCopyWith<$Res>(_self.location, (value) {
      return _then(_self.copyWith(location: value));
    });
  }
}

/// Adds pattern-matching-related methods to [GeometryDto].
extension GeometryDtoPatterns on GeometryDto {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_GeometryDto value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GeometryDto() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_GeometryDto value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GeometryDto():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_GeometryDto value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GeometryDto() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(LocationDto location)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GeometryDto() when $default != null:
        return $default(_that.location);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(LocationDto location) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GeometryDto():
        return $default(_that.location);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(LocationDto location)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GeometryDto() when $default != null:
        return $default(_that.location);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _GeometryDto implements GeometryDto {
  const _GeometryDto({required this.location});
  factory _GeometryDto.fromJson(Map<String, dynamic> json) =>
      _$GeometryDtoFromJson(json);

  @override
  final LocationDto location;

  /// Create a copy of GeometryDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$GeometryDtoCopyWith<_GeometryDto> get copyWith =>
      __$GeometryDtoCopyWithImpl<_GeometryDto>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$GeometryDtoToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _GeometryDto &&
            (identical(other.location, location) ||
                other.location == location));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, location);

  @override
  String toString() {
    return 'GeometryDto(location: $location)';
  }
}

/// @nodoc
abstract mixin class _$GeometryDtoCopyWith<$Res>
    implements $GeometryDtoCopyWith<$Res> {
  factory _$GeometryDtoCopyWith(
          _GeometryDto value, $Res Function(_GeometryDto) _then) =
      __$GeometryDtoCopyWithImpl;
  @override
  @useResult
  $Res call({LocationDto location});

  @override
  $LocationDtoCopyWith<$Res> get location;
}

/// @nodoc
class __$GeometryDtoCopyWithImpl<$Res> implements _$GeometryDtoCopyWith<$Res> {
  __$GeometryDtoCopyWithImpl(this._self, this._then);

  final _GeometryDto _self;
  final $Res Function(_GeometryDto) _then;

  /// Create a copy of GeometryDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? location = null,
  }) {
    return _then(_GeometryDto(
      location: null == location
          ? _self.location
          : location // ignore: cast_nullable_to_non_nullable
              as LocationDto,
    ));
  }

  /// Create a copy of GeometryDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LocationDtoCopyWith<$Res> get location {
    return $LocationDtoCopyWith<$Res>(_self.location, (value) {
      return _then(_self.copyWith(location: value));
    });
  }
}

/// @nodoc
mixin _$PlaceItemDto {
  @JsonKey(name: 'place_id')
  String get placeId;
  String get name;
  @JsonKey(name: 'formatted_address')
  String? get formattedAddress;
  String? get vicinity;
  GeometryDto? get geometry;
  double? get rating;
  @JsonKey(name: 'user_ratings_total')
  int? get userRatingsTotal;
  List<String> get types;
  @JsonKey(name: 'price_level')
  int? get priceLevel;

  /// Create a copy of PlaceItemDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PlaceItemDtoCopyWith<PlaceItemDto> get copyWith =>
      _$PlaceItemDtoCopyWithImpl<PlaceItemDto>(
          this as PlaceItemDto, _$identity);

  /// Serializes this PlaceItemDto to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PlaceItemDto &&
            (identical(other.placeId, placeId) || other.placeId == placeId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.formattedAddress, formattedAddress) ||
                other.formattedAddress == formattedAddress) &&
            (identical(other.vicinity, vicinity) ||
                other.vicinity == vicinity) &&
            (identical(other.geometry, geometry) ||
                other.geometry == geometry) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.userRatingsTotal, userRatingsTotal) ||
                other.userRatingsTotal == userRatingsTotal) &&
            const DeepCollectionEquality().equals(other.types, types) &&
            (identical(other.priceLevel, priceLevel) ||
                other.priceLevel == priceLevel));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      placeId,
      name,
      formattedAddress,
      vicinity,
      geometry,
      rating,
      userRatingsTotal,
      const DeepCollectionEquality().hash(types),
      priceLevel);

  @override
  String toString() {
    return 'PlaceItemDto(placeId: $placeId, name: $name, formattedAddress: $formattedAddress, vicinity: $vicinity, geometry: $geometry, rating: $rating, userRatingsTotal: $userRatingsTotal, types: $types, priceLevel: $priceLevel)';
  }
}

/// @nodoc
abstract mixin class $PlaceItemDtoCopyWith<$Res> {
  factory $PlaceItemDtoCopyWith(
          PlaceItemDto value, $Res Function(PlaceItemDto) _then) =
      _$PlaceItemDtoCopyWithImpl;
  @useResult
  $Res call(
      {@JsonKey(name: 'place_id') String placeId,
      String name,
      @JsonKey(name: 'formatted_address') String? formattedAddress,
      String? vicinity,
      GeometryDto? geometry,
      double? rating,
      @JsonKey(name: 'user_ratings_total') int? userRatingsTotal,
      List<String> types,
      @JsonKey(name: 'price_level') int? priceLevel});

  $GeometryDtoCopyWith<$Res>? get geometry;
}

/// @nodoc
class _$PlaceItemDtoCopyWithImpl<$Res> implements $PlaceItemDtoCopyWith<$Res> {
  _$PlaceItemDtoCopyWithImpl(this._self, this._then);

  final PlaceItemDto _self;
  final $Res Function(PlaceItemDto) _then;

  /// Create a copy of PlaceItemDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? placeId = null,
    Object? name = null,
    Object? formattedAddress = freezed,
    Object? vicinity = freezed,
    Object? geometry = freezed,
    Object? rating = freezed,
    Object? userRatingsTotal = freezed,
    Object? types = null,
    Object? priceLevel = freezed,
  }) {
    return _then(_self.copyWith(
      placeId: null == placeId
          ? _self.placeId
          : placeId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      formattedAddress: freezed == formattedAddress
          ? _self.formattedAddress
          : formattedAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      vicinity: freezed == vicinity
          ? _self.vicinity
          : vicinity // ignore: cast_nullable_to_non_nullable
              as String?,
      geometry: freezed == geometry
          ? _self.geometry
          : geometry // ignore: cast_nullable_to_non_nullable
              as GeometryDto?,
      rating: freezed == rating
          ? _self.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double?,
      userRatingsTotal: freezed == userRatingsTotal
          ? _self.userRatingsTotal
          : userRatingsTotal // ignore: cast_nullable_to_non_nullable
              as int?,
      types: null == types
          ? _self.types
          : types // ignore: cast_nullable_to_non_nullable
              as List<String>,
      priceLevel: freezed == priceLevel
          ? _self.priceLevel
          : priceLevel // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }

  /// Create a copy of PlaceItemDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GeometryDtoCopyWith<$Res>? get geometry {
    if (_self.geometry == null) {
      return null;
    }

    return $GeometryDtoCopyWith<$Res>(_self.geometry!, (value) {
      return _then(_self.copyWith(geometry: value));
    });
  }
}

/// Adds pattern-matching-related methods to [PlaceItemDto].
extension PlaceItemDtoPatterns on PlaceItemDto {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_PlaceItemDto value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PlaceItemDto() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_PlaceItemDto value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PlaceItemDto():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_PlaceItemDto value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PlaceItemDto() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            @JsonKey(name: 'place_id') String placeId,
            String name,
            @JsonKey(name: 'formatted_address') String? formattedAddress,
            String? vicinity,
            GeometryDto? geometry,
            double? rating,
            @JsonKey(name: 'user_ratings_total') int? userRatingsTotal,
            List<String> types,
            @JsonKey(name: 'price_level') int? priceLevel)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PlaceItemDto() when $default != null:
        return $default(
            _that.placeId,
            _that.name,
            _that.formattedAddress,
            _that.vicinity,
            _that.geometry,
            _that.rating,
            _that.userRatingsTotal,
            _that.types,
            _that.priceLevel);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            @JsonKey(name: 'place_id') String placeId,
            String name,
            @JsonKey(name: 'formatted_address') String? formattedAddress,
            String? vicinity,
            GeometryDto? geometry,
            double? rating,
            @JsonKey(name: 'user_ratings_total') int? userRatingsTotal,
            List<String> types,
            @JsonKey(name: 'price_level') int? priceLevel)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PlaceItemDto():
        return $default(
            _that.placeId,
            _that.name,
            _that.formattedAddress,
            _that.vicinity,
            _that.geometry,
            _that.rating,
            _that.userRatingsTotal,
            _that.types,
            _that.priceLevel);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            @JsonKey(name: 'place_id') String placeId,
            String name,
            @JsonKey(name: 'formatted_address') String? formattedAddress,
            String? vicinity,
            GeometryDto? geometry,
            double? rating,
            @JsonKey(name: 'user_ratings_total') int? userRatingsTotal,
            List<String> types,
            @JsonKey(name: 'price_level') int? priceLevel)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PlaceItemDto() when $default != null:
        return $default(
            _that.placeId,
            _that.name,
            _that.formattedAddress,
            _that.vicinity,
            _that.geometry,
            _that.rating,
            _that.userRatingsTotal,
            _that.types,
            _that.priceLevel);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _PlaceItemDto implements PlaceItemDto {
  const _PlaceItemDto(
      {@JsonKey(name: 'place_id') required this.placeId,
      required this.name,
      @JsonKey(name: 'formatted_address') this.formattedAddress,
      this.vicinity,
      this.geometry,
      this.rating,
      @JsonKey(name: 'user_ratings_total') this.userRatingsTotal,
      final List<String> types = const <String>[],
      @JsonKey(name: 'price_level') this.priceLevel})
      : _types = types;
  factory _PlaceItemDto.fromJson(Map<String, dynamic> json) =>
      _$PlaceItemDtoFromJson(json);

  @override
  @JsonKey(name: 'place_id')
  final String placeId;
  @override
  final String name;
  @override
  @JsonKey(name: 'formatted_address')
  final String? formattedAddress;
  @override
  final String? vicinity;
  @override
  final GeometryDto? geometry;
  @override
  final double? rating;
  @override
  @JsonKey(name: 'user_ratings_total')
  final int? userRatingsTotal;
  final List<String> _types;
  @override
  @JsonKey()
  List<String> get types {
    if (_types is EqualUnmodifiableListView) return _types;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_types);
  }

  @override
  @JsonKey(name: 'price_level')
  final int? priceLevel;

  /// Create a copy of PlaceItemDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PlaceItemDtoCopyWith<_PlaceItemDto> get copyWith =>
      __$PlaceItemDtoCopyWithImpl<_PlaceItemDto>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$PlaceItemDtoToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PlaceItemDto &&
            (identical(other.placeId, placeId) || other.placeId == placeId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.formattedAddress, formattedAddress) ||
                other.formattedAddress == formattedAddress) &&
            (identical(other.vicinity, vicinity) ||
                other.vicinity == vicinity) &&
            (identical(other.geometry, geometry) ||
                other.geometry == geometry) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.userRatingsTotal, userRatingsTotal) ||
                other.userRatingsTotal == userRatingsTotal) &&
            const DeepCollectionEquality().equals(other._types, _types) &&
            (identical(other.priceLevel, priceLevel) ||
                other.priceLevel == priceLevel));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      placeId,
      name,
      formattedAddress,
      vicinity,
      geometry,
      rating,
      userRatingsTotal,
      const DeepCollectionEquality().hash(_types),
      priceLevel);

  @override
  String toString() {
    return 'PlaceItemDto(placeId: $placeId, name: $name, formattedAddress: $formattedAddress, vicinity: $vicinity, geometry: $geometry, rating: $rating, userRatingsTotal: $userRatingsTotal, types: $types, priceLevel: $priceLevel)';
  }
}

/// @nodoc
abstract mixin class _$PlaceItemDtoCopyWith<$Res>
    implements $PlaceItemDtoCopyWith<$Res> {
  factory _$PlaceItemDtoCopyWith(
          _PlaceItemDto value, $Res Function(_PlaceItemDto) _then) =
      __$PlaceItemDtoCopyWithImpl;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'place_id') String placeId,
      String name,
      @JsonKey(name: 'formatted_address') String? formattedAddress,
      String? vicinity,
      GeometryDto? geometry,
      double? rating,
      @JsonKey(name: 'user_ratings_total') int? userRatingsTotal,
      List<String> types,
      @JsonKey(name: 'price_level') int? priceLevel});

  @override
  $GeometryDtoCopyWith<$Res>? get geometry;
}

/// @nodoc
class __$PlaceItemDtoCopyWithImpl<$Res>
    implements _$PlaceItemDtoCopyWith<$Res> {
  __$PlaceItemDtoCopyWithImpl(this._self, this._then);

  final _PlaceItemDto _self;
  final $Res Function(_PlaceItemDto) _then;

  /// Create a copy of PlaceItemDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? placeId = null,
    Object? name = null,
    Object? formattedAddress = freezed,
    Object? vicinity = freezed,
    Object? geometry = freezed,
    Object? rating = freezed,
    Object? userRatingsTotal = freezed,
    Object? types = null,
    Object? priceLevel = freezed,
  }) {
    return _then(_PlaceItemDto(
      placeId: null == placeId
          ? _self.placeId
          : placeId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      formattedAddress: freezed == formattedAddress
          ? _self.formattedAddress
          : formattedAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      vicinity: freezed == vicinity
          ? _self.vicinity
          : vicinity // ignore: cast_nullable_to_non_nullable
              as String?,
      geometry: freezed == geometry
          ? _self.geometry
          : geometry // ignore: cast_nullable_to_non_nullable
              as GeometryDto?,
      rating: freezed == rating
          ? _self.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double?,
      userRatingsTotal: freezed == userRatingsTotal
          ? _self.userRatingsTotal
          : userRatingsTotal // ignore: cast_nullable_to_non_nullable
              as int?,
      types: null == types
          ? _self._types
          : types // ignore: cast_nullable_to_non_nullable
              as List<String>,
      priceLevel: freezed == priceLevel
          ? _self.priceLevel
          : priceLevel // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }

  /// Create a copy of PlaceItemDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GeometryDtoCopyWith<$Res>? get geometry {
    if (_self.geometry == null) {
      return null;
    }

    return $GeometryDtoCopyWith<$Res>(_self.geometry!, (value) {
      return _then(_self.copyWith(geometry: value));
    });
  }
}

/// @nodoc
mixin _$OpeningHoursDto {
  @JsonKey(name: 'weekday_text')
  List<String> get weekdayText;

  /// Create a copy of OpeningHoursDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $OpeningHoursDtoCopyWith<OpeningHoursDto> get copyWith =>
      _$OpeningHoursDtoCopyWithImpl<OpeningHoursDto>(
          this as OpeningHoursDto, _$identity);

  /// Serializes this OpeningHoursDto to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is OpeningHoursDto &&
            const DeepCollectionEquality()
                .equals(other.weekdayText, weekdayText));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(weekdayText));

  @override
  String toString() {
    return 'OpeningHoursDto(weekdayText: $weekdayText)';
  }
}

/// @nodoc
abstract mixin class $OpeningHoursDtoCopyWith<$Res> {
  factory $OpeningHoursDtoCopyWith(
          OpeningHoursDto value, $Res Function(OpeningHoursDto) _then) =
      _$OpeningHoursDtoCopyWithImpl;
  @useResult
  $Res call({@JsonKey(name: 'weekday_text') List<String> weekdayText});
}

/// @nodoc
class _$OpeningHoursDtoCopyWithImpl<$Res>
    implements $OpeningHoursDtoCopyWith<$Res> {
  _$OpeningHoursDtoCopyWithImpl(this._self, this._then);

  final OpeningHoursDto _self;
  final $Res Function(OpeningHoursDto) _then;

  /// Create a copy of OpeningHoursDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? weekdayText = null,
  }) {
    return _then(_self.copyWith(
      weekdayText: null == weekdayText
          ? _self.weekdayText
          : weekdayText // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// Adds pattern-matching-related methods to [OpeningHoursDto].
extension OpeningHoursDtoPatterns on OpeningHoursDto {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_OpeningHoursDto value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _OpeningHoursDto() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_OpeningHoursDto value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OpeningHoursDto():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_OpeningHoursDto value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OpeningHoursDto() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(@JsonKey(name: 'weekday_text') List<String> weekdayText)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _OpeningHoursDto() when $default != null:
        return $default(_that.weekdayText);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(@JsonKey(name: 'weekday_text') List<String> weekdayText)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OpeningHoursDto():
        return $default(_that.weekdayText);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(@JsonKey(name: 'weekday_text') List<String> weekdayText)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OpeningHoursDto() when $default != null:
        return $default(_that.weekdayText);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _OpeningHoursDto implements OpeningHoursDto {
  const _OpeningHoursDto(
      {@JsonKey(name: 'weekday_text')
      final List<String> weekdayText = const <String>[]})
      : _weekdayText = weekdayText;
  factory _OpeningHoursDto.fromJson(Map<String, dynamic> json) =>
      _$OpeningHoursDtoFromJson(json);

  final List<String> _weekdayText;
  @override
  @JsonKey(name: 'weekday_text')
  List<String> get weekdayText {
    if (_weekdayText is EqualUnmodifiableListView) return _weekdayText;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_weekdayText);
  }

  /// Create a copy of OpeningHoursDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$OpeningHoursDtoCopyWith<_OpeningHoursDto> get copyWith =>
      __$OpeningHoursDtoCopyWithImpl<_OpeningHoursDto>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$OpeningHoursDtoToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _OpeningHoursDto &&
            const DeepCollectionEquality()
                .equals(other._weekdayText, _weekdayText));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_weekdayText));

  @override
  String toString() {
    return 'OpeningHoursDto(weekdayText: $weekdayText)';
  }
}

/// @nodoc
abstract mixin class _$OpeningHoursDtoCopyWith<$Res>
    implements $OpeningHoursDtoCopyWith<$Res> {
  factory _$OpeningHoursDtoCopyWith(
          _OpeningHoursDto value, $Res Function(_OpeningHoursDto) _then) =
      __$OpeningHoursDtoCopyWithImpl;
  @override
  @useResult
  $Res call({@JsonKey(name: 'weekday_text') List<String> weekdayText});
}

/// @nodoc
class __$OpeningHoursDtoCopyWithImpl<$Res>
    implements _$OpeningHoursDtoCopyWith<$Res> {
  __$OpeningHoursDtoCopyWithImpl(this._self, this._then);

  final _OpeningHoursDto _self;
  final $Res Function(_OpeningHoursDto) _then;

  /// Create a copy of OpeningHoursDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? weekdayText = null,
  }) {
    return _then(_OpeningHoursDto(
      weekdayText: null == weekdayText
          ? _self._weekdayText
          : weekdayText // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
mixin _$PhotoDto {
  @JsonKey(name: 'photo_reference')
  String? get photoReference;
  int? get width;
  int? get height;

  /// Create a copy of PhotoDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PhotoDtoCopyWith<PhotoDto> get copyWith =>
      _$PhotoDtoCopyWithImpl<PhotoDto>(this as PhotoDto, _$identity);

  /// Serializes this PhotoDto to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PhotoDto &&
            (identical(other.photoReference, photoReference) ||
                other.photoReference == photoReference) &&
            (identical(other.width, width) || other.width == width) &&
            (identical(other.height, height) || other.height == height));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, photoReference, width, height);

  @override
  String toString() {
    return 'PhotoDto(photoReference: $photoReference, width: $width, height: $height)';
  }
}

/// @nodoc
abstract mixin class $PhotoDtoCopyWith<$Res> {
  factory $PhotoDtoCopyWith(PhotoDto value, $Res Function(PhotoDto) _then) =
      _$PhotoDtoCopyWithImpl;
  @useResult
  $Res call(
      {@JsonKey(name: 'photo_reference') String? photoReference,
      int? width,
      int? height});
}

/// @nodoc
class _$PhotoDtoCopyWithImpl<$Res> implements $PhotoDtoCopyWith<$Res> {
  _$PhotoDtoCopyWithImpl(this._self, this._then);

  final PhotoDto _self;
  final $Res Function(PhotoDto) _then;

  /// Create a copy of PhotoDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? photoReference = freezed,
    Object? width = freezed,
    Object? height = freezed,
  }) {
    return _then(_self.copyWith(
      photoReference: freezed == photoReference
          ? _self.photoReference
          : photoReference // ignore: cast_nullable_to_non_nullable
              as String?,
      width: freezed == width
          ? _self.width
          : width // ignore: cast_nullable_to_non_nullable
              as int?,
      height: freezed == height
          ? _self.height
          : height // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// Adds pattern-matching-related methods to [PhotoDto].
extension PhotoDtoPatterns on PhotoDto {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_PhotoDto value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PhotoDto() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_PhotoDto value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PhotoDto():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_PhotoDto value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PhotoDto() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(@JsonKey(name: 'photo_reference') String? photoReference,
            int? width, int? height)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PhotoDto() when $default != null:
        return $default(_that.photoReference, _that.width, _that.height);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(@JsonKey(name: 'photo_reference') String? photoReference,
            int? width, int? height)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PhotoDto():
        return $default(_that.photoReference, _that.width, _that.height);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(@JsonKey(name: 'photo_reference') String? photoReference,
            int? width, int? height)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PhotoDto() when $default != null:
        return $default(_that.photoReference, _that.width, _that.height);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _PhotoDto implements PhotoDto {
  const _PhotoDto(
      {@JsonKey(name: 'photo_reference') this.photoReference,
      this.width,
      this.height});
  factory _PhotoDto.fromJson(Map<String, dynamic> json) =>
      _$PhotoDtoFromJson(json);

  @override
  @JsonKey(name: 'photo_reference')
  final String? photoReference;
  @override
  final int? width;
  @override
  final int? height;

  /// Create a copy of PhotoDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PhotoDtoCopyWith<_PhotoDto> get copyWith =>
      __$PhotoDtoCopyWithImpl<_PhotoDto>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$PhotoDtoToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PhotoDto &&
            (identical(other.photoReference, photoReference) ||
                other.photoReference == photoReference) &&
            (identical(other.width, width) || other.width == width) &&
            (identical(other.height, height) || other.height == height));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, photoReference, width, height);

  @override
  String toString() {
    return 'PhotoDto(photoReference: $photoReference, width: $width, height: $height)';
  }
}

/// @nodoc
abstract mixin class _$PhotoDtoCopyWith<$Res>
    implements $PhotoDtoCopyWith<$Res> {
  factory _$PhotoDtoCopyWith(_PhotoDto value, $Res Function(_PhotoDto) _then) =
      __$PhotoDtoCopyWithImpl;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'photo_reference') String? photoReference,
      int? width,
      int? height});
}

/// @nodoc
class __$PhotoDtoCopyWithImpl<$Res> implements _$PhotoDtoCopyWith<$Res> {
  __$PhotoDtoCopyWithImpl(this._self, this._then);

  final _PhotoDto _self;
  final $Res Function(_PhotoDto) _then;

  /// Create a copy of PhotoDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? photoReference = freezed,
    Object? width = freezed,
    Object? height = freezed,
  }) {
    return _then(_PhotoDto(
      photoReference: freezed == photoReference
          ? _self.photoReference
          : photoReference // ignore: cast_nullable_to_non_nullable
              as String?,
      width: freezed == width
          ? _self.width
          : width // ignore: cast_nullable_to_non_nullable
              as int?,
      height: freezed == height
          ? _self.height
          : height // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
mixin _$PlaceDetailsDto {
  @JsonKey(name: 'place_id')
  String get placeId;
  String get name;
  @JsonKey(name: 'formatted_address')
  String? get formattedAddress;
  GeometryDto? get geometry;
  double? get rating;
  @JsonKey(name: 'user_ratings_total')
  int? get userRatingsTotal;
  List<String> get types;
  @JsonKey(name: 'price_level')
  int? get priceLevel;
  @JsonKey(name: 'formatted_phone_number')
  String? get formattedPhoneNumber;
  String? get website;
  @JsonKey(name: 'opening_hours')
  OpeningHoursDto? get openingHours;
  List<PhotoDto> get photos;

  /// Create a copy of PlaceDetailsDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PlaceDetailsDtoCopyWith<PlaceDetailsDto> get copyWith =>
      _$PlaceDetailsDtoCopyWithImpl<PlaceDetailsDto>(
          this as PlaceDetailsDto, _$identity);

  /// Serializes this PlaceDetailsDto to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PlaceDetailsDto &&
            (identical(other.placeId, placeId) || other.placeId == placeId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.formattedAddress, formattedAddress) ||
                other.formattedAddress == formattedAddress) &&
            (identical(other.geometry, geometry) ||
                other.geometry == geometry) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.userRatingsTotal, userRatingsTotal) ||
                other.userRatingsTotal == userRatingsTotal) &&
            const DeepCollectionEquality().equals(other.types, types) &&
            (identical(other.priceLevel, priceLevel) ||
                other.priceLevel == priceLevel) &&
            (identical(other.formattedPhoneNumber, formattedPhoneNumber) ||
                other.formattedPhoneNumber == formattedPhoneNumber) &&
            (identical(other.website, website) || other.website == website) &&
            (identical(other.openingHours, openingHours) ||
                other.openingHours == openingHours) &&
            const DeepCollectionEquality().equals(other.photos, photos));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      placeId,
      name,
      formattedAddress,
      geometry,
      rating,
      userRatingsTotal,
      const DeepCollectionEquality().hash(types),
      priceLevel,
      formattedPhoneNumber,
      website,
      openingHours,
      const DeepCollectionEquality().hash(photos));

  @override
  String toString() {
    return 'PlaceDetailsDto(placeId: $placeId, name: $name, formattedAddress: $formattedAddress, geometry: $geometry, rating: $rating, userRatingsTotal: $userRatingsTotal, types: $types, priceLevel: $priceLevel, formattedPhoneNumber: $formattedPhoneNumber, website: $website, openingHours: $openingHours, photos: $photos)';
  }
}

/// @nodoc
abstract mixin class $PlaceDetailsDtoCopyWith<$Res> {
  factory $PlaceDetailsDtoCopyWith(
          PlaceDetailsDto value, $Res Function(PlaceDetailsDto) _then) =
      _$PlaceDetailsDtoCopyWithImpl;
  @useResult
  $Res call(
      {@JsonKey(name: 'place_id') String placeId,
      String name,
      @JsonKey(name: 'formatted_address') String? formattedAddress,
      GeometryDto? geometry,
      double? rating,
      @JsonKey(name: 'user_ratings_total') int? userRatingsTotal,
      List<String> types,
      @JsonKey(name: 'price_level') int? priceLevel,
      @JsonKey(name: 'formatted_phone_number') String? formattedPhoneNumber,
      String? website,
      @JsonKey(name: 'opening_hours') OpeningHoursDto? openingHours,
      List<PhotoDto> photos});

  $GeometryDtoCopyWith<$Res>? get geometry;
  $OpeningHoursDtoCopyWith<$Res>? get openingHours;
}

/// @nodoc
class _$PlaceDetailsDtoCopyWithImpl<$Res>
    implements $PlaceDetailsDtoCopyWith<$Res> {
  _$PlaceDetailsDtoCopyWithImpl(this._self, this._then);

  final PlaceDetailsDto _self;
  final $Res Function(PlaceDetailsDto) _then;

  /// Create a copy of PlaceDetailsDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? placeId = null,
    Object? name = null,
    Object? formattedAddress = freezed,
    Object? geometry = freezed,
    Object? rating = freezed,
    Object? userRatingsTotal = freezed,
    Object? types = null,
    Object? priceLevel = freezed,
    Object? formattedPhoneNumber = freezed,
    Object? website = freezed,
    Object? openingHours = freezed,
    Object? photos = null,
  }) {
    return _then(_self.copyWith(
      placeId: null == placeId
          ? _self.placeId
          : placeId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      formattedAddress: freezed == formattedAddress
          ? _self.formattedAddress
          : formattedAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      geometry: freezed == geometry
          ? _self.geometry
          : geometry // ignore: cast_nullable_to_non_nullable
              as GeometryDto?,
      rating: freezed == rating
          ? _self.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double?,
      userRatingsTotal: freezed == userRatingsTotal
          ? _self.userRatingsTotal
          : userRatingsTotal // ignore: cast_nullable_to_non_nullable
              as int?,
      types: null == types
          ? _self.types
          : types // ignore: cast_nullable_to_non_nullable
              as List<String>,
      priceLevel: freezed == priceLevel
          ? _self.priceLevel
          : priceLevel // ignore: cast_nullable_to_non_nullable
              as int?,
      formattedPhoneNumber: freezed == formattedPhoneNumber
          ? _self.formattedPhoneNumber
          : formattedPhoneNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      website: freezed == website
          ? _self.website
          : website // ignore: cast_nullable_to_non_nullable
              as String?,
      openingHours: freezed == openingHours
          ? _self.openingHours
          : openingHours // ignore: cast_nullable_to_non_nullable
              as OpeningHoursDto?,
      photos: null == photos
          ? _self.photos
          : photos // ignore: cast_nullable_to_non_nullable
              as List<PhotoDto>,
    ));
  }

  /// Create a copy of PlaceDetailsDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GeometryDtoCopyWith<$Res>? get geometry {
    if (_self.geometry == null) {
      return null;
    }

    return $GeometryDtoCopyWith<$Res>(_self.geometry!, (value) {
      return _then(_self.copyWith(geometry: value));
    });
  }

  /// Create a copy of PlaceDetailsDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $OpeningHoursDtoCopyWith<$Res>? get openingHours {
    if (_self.openingHours == null) {
      return null;
    }

    return $OpeningHoursDtoCopyWith<$Res>(_self.openingHours!, (value) {
      return _then(_self.copyWith(openingHours: value));
    });
  }
}

/// Adds pattern-matching-related methods to [PlaceDetailsDto].
extension PlaceDetailsDtoPatterns on PlaceDetailsDto {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_PlaceDetailsDto value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PlaceDetailsDto() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_PlaceDetailsDto value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PlaceDetailsDto():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_PlaceDetailsDto value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PlaceDetailsDto() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            @JsonKey(name: 'place_id') String placeId,
            String name,
            @JsonKey(name: 'formatted_address') String? formattedAddress,
            GeometryDto? geometry,
            double? rating,
            @JsonKey(name: 'user_ratings_total') int? userRatingsTotal,
            List<String> types,
            @JsonKey(name: 'price_level') int? priceLevel,
            @JsonKey(name: 'formatted_phone_number')
            String? formattedPhoneNumber,
            String? website,
            @JsonKey(name: 'opening_hours') OpeningHoursDto? openingHours,
            List<PhotoDto> photos)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PlaceDetailsDto() when $default != null:
        return $default(
            _that.placeId,
            _that.name,
            _that.formattedAddress,
            _that.geometry,
            _that.rating,
            _that.userRatingsTotal,
            _that.types,
            _that.priceLevel,
            _that.formattedPhoneNumber,
            _that.website,
            _that.openingHours,
            _that.photos);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            @JsonKey(name: 'place_id') String placeId,
            String name,
            @JsonKey(name: 'formatted_address') String? formattedAddress,
            GeometryDto? geometry,
            double? rating,
            @JsonKey(name: 'user_ratings_total') int? userRatingsTotal,
            List<String> types,
            @JsonKey(name: 'price_level') int? priceLevel,
            @JsonKey(name: 'formatted_phone_number')
            String? formattedPhoneNumber,
            String? website,
            @JsonKey(name: 'opening_hours') OpeningHoursDto? openingHours,
            List<PhotoDto> photos)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PlaceDetailsDto():
        return $default(
            _that.placeId,
            _that.name,
            _that.formattedAddress,
            _that.geometry,
            _that.rating,
            _that.userRatingsTotal,
            _that.types,
            _that.priceLevel,
            _that.formattedPhoneNumber,
            _that.website,
            _that.openingHours,
            _that.photos);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            @JsonKey(name: 'place_id') String placeId,
            String name,
            @JsonKey(name: 'formatted_address') String? formattedAddress,
            GeometryDto? geometry,
            double? rating,
            @JsonKey(name: 'user_ratings_total') int? userRatingsTotal,
            List<String> types,
            @JsonKey(name: 'price_level') int? priceLevel,
            @JsonKey(name: 'formatted_phone_number')
            String? formattedPhoneNumber,
            String? website,
            @JsonKey(name: 'opening_hours') OpeningHoursDto? openingHours,
            List<PhotoDto> photos)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PlaceDetailsDto() when $default != null:
        return $default(
            _that.placeId,
            _that.name,
            _that.formattedAddress,
            _that.geometry,
            _that.rating,
            _that.userRatingsTotal,
            _that.types,
            _that.priceLevel,
            _that.formattedPhoneNumber,
            _that.website,
            _that.openingHours,
            _that.photos);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _PlaceDetailsDto implements PlaceDetailsDto {
  const _PlaceDetailsDto(
      {@JsonKey(name: 'place_id') required this.placeId,
      required this.name,
      @JsonKey(name: 'formatted_address') this.formattedAddress,
      this.geometry,
      this.rating,
      @JsonKey(name: 'user_ratings_total') this.userRatingsTotal,
      final List<String> types = const <String>[],
      @JsonKey(name: 'price_level') this.priceLevel,
      @JsonKey(name: 'formatted_phone_number') this.formattedPhoneNumber,
      this.website,
      @JsonKey(name: 'opening_hours') this.openingHours,
      final List<PhotoDto> photos = const <PhotoDto>[]})
      : _types = types,
        _photos = photos;
  factory _PlaceDetailsDto.fromJson(Map<String, dynamic> json) =>
      _$PlaceDetailsDtoFromJson(json);

  @override
  @JsonKey(name: 'place_id')
  final String placeId;
  @override
  final String name;
  @override
  @JsonKey(name: 'formatted_address')
  final String? formattedAddress;
  @override
  final GeometryDto? geometry;
  @override
  final double? rating;
  @override
  @JsonKey(name: 'user_ratings_total')
  final int? userRatingsTotal;
  final List<String> _types;
  @override
  @JsonKey()
  List<String> get types {
    if (_types is EqualUnmodifiableListView) return _types;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_types);
  }

  @override
  @JsonKey(name: 'price_level')
  final int? priceLevel;
  @override
  @JsonKey(name: 'formatted_phone_number')
  final String? formattedPhoneNumber;
  @override
  final String? website;
  @override
  @JsonKey(name: 'opening_hours')
  final OpeningHoursDto? openingHours;
  final List<PhotoDto> _photos;
  @override
  @JsonKey()
  List<PhotoDto> get photos {
    if (_photos is EqualUnmodifiableListView) return _photos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_photos);
  }

  /// Create a copy of PlaceDetailsDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PlaceDetailsDtoCopyWith<_PlaceDetailsDto> get copyWith =>
      __$PlaceDetailsDtoCopyWithImpl<_PlaceDetailsDto>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$PlaceDetailsDtoToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PlaceDetailsDto &&
            (identical(other.placeId, placeId) || other.placeId == placeId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.formattedAddress, formattedAddress) ||
                other.formattedAddress == formattedAddress) &&
            (identical(other.geometry, geometry) ||
                other.geometry == geometry) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.userRatingsTotal, userRatingsTotal) ||
                other.userRatingsTotal == userRatingsTotal) &&
            const DeepCollectionEquality().equals(other._types, _types) &&
            (identical(other.priceLevel, priceLevel) ||
                other.priceLevel == priceLevel) &&
            (identical(other.formattedPhoneNumber, formattedPhoneNumber) ||
                other.formattedPhoneNumber == formattedPhoneNumber) &&
            (identical(other.website, website) || other.website == website) &&
            (identical(other.openingHours, openingHours) ||
                other.openingHours == openingHours) &&
            const DeepCollectionEquality().equals(other._photos, _photos));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      placeId,
      name,
      formattedAddress,
      geometry,
      rating,
      userRatingsTotal,
      const DeepCollectionEquality().hash(_types),
      priceLevel,
      formattedPhoneNumber,
      website,
      openingHours,
      const DeepCollectionEquality().hash(_photos));

  @override
  String toString() {
    return 'PlaceDetailsDto(placeId: $placeId, name: $name, formattedAddress: $formattedAddress, geometry: $geometry, rating: $rating, userRatingsTotal: $userRatingsTotal, types: $types, priceLevel: $priceLevel, formattedPhoneNumber: $formattedPhoneNumber, website: $website, openingHours: $openingHours, photos: $photos)';
  }
}

/// @nodoc
abstract mixin class _$PlaceDetailsDtoCopyWith<$Res>
    implements $PlaceDetailsDtoCopyWith<$Res> {
  factory _$PlaceDetailsDtoCopyWith(
          _PlaceDetailsDto value, $Res Function(_PlaceDetailsDto) _then) =
      __$PlaceDetailsDtoCopyWithImpl;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'place_id') String placeId,
      String name,
      @JsonKey(name: 'formatted_address') String? formattedAddress,
      GeometryDto? geometry,
      double? rating,
      @JsonKey(name: 'user_ratings_total') int? userRatingsTotal,
      List<String> types,
      @JsonKey(name: 'price_level') int? priceLevel,
      @JsonKey(name: 'formatted_phone_number') String? formattedPhoneNumber,
      String? website,
      @JsonKey(name: 'opening_hours') OpeningHoursDto? openingHours,
      List<PhotoDto> photos});

  @override
  $GeometryDtoCopyWith<$Res>? get geometry;
  @override
  $OpeningHoursDtoCopyWith<$Res>? get openingHours;
}

/// @nodoc
class __$PlaceDetailsDtoCopyWithImpl<$Res>
    implements _$PlaceDetailsDtoCopyWith<$Res> {
  __$PlaceDetailsDtoCopyWithImpl(this._self, this._then);

  final _PlaceDetailsDto _self;
  final $Res Function(_PlaceDetailsDto) _then;

  /// Create a copy of PlaceDetailsDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? placeId = null,
    Object? name = null,
    Object? formattedAddress = freezed,
    Object? geometry = freezed,
    Object? rating = freezed,
    Object? userRatingsTotal = freezed,
    Object? types = null,
    Object? priceLevel = freezed,
    Object? formattedPhoneNumber = freezed,
    Object? website = freezed,
    Object? openingHours = freezed,
    Object? photos = null,
  }) {
    return _then(_PlaceDetailsDto(
      placeId: null == placeId
          ? _self.placeId
          : placeId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      formattedAddress: freezed == formattedAddress
          ? _self.formattedAddress
          : formattedAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      geometry: freezed == geometry
          ? _self.geometry
          : geometry // ignore: cast_nullable_to_non_nullable
              as GeometryDto?,
      rating: freezed == rating
          ? _self.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double?,
      userRatingsTotal: freezed == userRatingsTotal
          ? _self.userRatingsTotal
          : userRatingsTotal // ignore: cast_nullable_to_non_nullable
              as int?,
      types: null == types
          ? _self._types
          : types // ignore: cast_nullable_to_non_nullable
              as List<String>,
      priceLevel: freezed == priceLevel
          ? _self.priceLevel
          : priceLevel // ignore: cast_nullable_to_non_nullable
              as int?,
      formattedPhoneNumber: freezed == formattedPhoneNumber
          ? _self.formattedPhoneNumber
          : formattedPhoneNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      website: freezed == website
          ? _self.website
          : website // ignore: cast_nullable_to_non_nullable
              as String?,
      openingHours: freezed == openingHours
          ? _self.openingHours
          : openingHours // ignore: cast_nullable_to_non_nullable
              as OpeningHoursDto?,
      photos: null == photos
          ? _self._photos
          : photos // ignore: cast_nullable_to_non_nullable
              as List<PhotoDto>,
    ));
  }

  /// Create a copy of PlaceDetailsDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GeometryDtoCopyWith<$Res>? get geometry {
    if (_self.geometry == null) {
      return null;
    }

    return $GeometryDtoCopyWith<$Res>(_self.geometry!, (value) {
      return _then(_self.copyWith(geometry: value));
    });
  }

  /// Create a copy of PlaceDetailsDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $OpeningHoursDtoCopyWith<$Res>? get openingHours {
    if (_self.openingHours == null) {
      return null;
    }

    return $OpeningHoursDtoCopyWith<$Res>(_self.openingHours!, (value) {
      return _then(_self.copyWith(openingHours: value));
    });
  }
}

/// @nodoc
mixin _$TextSearchResponseDto {
  List<PlaceItemDto> get results;
  String? get status;

  /// Create a copy of TextSearchResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TextSearchResponseDtoCopyWith<TextSearchResponseDto> get copyWith =>
      _$TextSearchResponseDtoCopyWithImpl<TextSearchResponseDto>(
          this as TextSearchResponseDto, _$identity);

  /// Serializes this TextSearchResponseDto to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TextSearchResponseDto &&
            const DeepCollectionEquality().equals(other.results, results) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(results), status);

  @override
  String toString() {
    return 'TextSearchResponseDto(results: $results, status: $status)';
  }
}

/// @nodoc
abstract mixin class $TextSearchResponseDtoCopyWith<$Res> {
  factory $TextSearchResponseDtoCopyWith(TextSearchResponseDto value,
          $Res Function(TextSearchResponseDto) _then) =
      _$TextSearchResponseDtoCopyWithImpl;
  @useResult
  $Res call({List<PlaceItemDto> results, String? status});
}

/// @nodoc
class _$TextSearchResponseDtoCopyWithImpl<$Res>
    implements $TextSearchResponseDtoCopyWith<$Res> {
  _$TextSearchResponseDtoCopyWithImpl(this._self, this._then);

  final TextSearchResponseDto _self;
  final $Res Function(TextSearchResponseDto) _then;

  /// Create a copy of TextSearchResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? results = null,
    Object? status = freezed,
  }) {
    return _then(_self.copyWith(
      results: null == results
          ? _self.results
          : results // ignore: cast_nullable_to_non_nullable
              as List<PlaceItemDto>,
      status: freezed == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [TextSearchResponseDto].
extension TextSearchResponseDtoPatterns on TextSearchResponseDto {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_TextSearchResponseDto value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TextSearchResponseDto() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_TextSearchResponseDto value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TextSearchResponseDto():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_TextSearchResponseDto value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TextSearchResponseDto() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(List<PlaceItemDto> results, String? status)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TextSearchResponseDto() when $default != null:
        return $default(_that.results, _that.status);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(List<PlaceItemDto> results, String? status) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TextSearchResponseDto():
        return $default(_that.results, _that.status);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(List<PlaceItemDto> results, String? status)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TextSearchResponseDto() when $default != null:
        return $default(_that.results, _that.status);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _TextSearchResponseDto implements TextSearchResponseDto {
  const _TextSearchResponseDto(
      {final List<PlaceItemDto> results = const <PlaceItemDto>[], this.status})
      : _results = results;
  factory _TextSearchResponseDto.fromJson(Map<String, dynamic> json) =>
      _$TextSearchResponseDtoFromJson(json);

  final List<PlaceItemDto> _results;
  @override
  @JsonKey()
  List<PlaceItemDto> get results {
    if (_results is EqualUnmodifiableListView) return _results;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_results);
  }

  @override
  final String? status;

  /// Create a copy of TextSearchResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$TextSearchResponseDtoCopyWith<_TextSearchResponseDto> get copyWith =>
      __$TextSearchResponseDtoCopyWithImpl<_TextSearchResponseDto>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$TextSearchResponseDtoToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _TextSearchResponseDto &&
            const DeepCollectionEquality().equals(other._results, _results) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_results), status);

  @override
  String toString() {
    return 'TextSearchResponseDto(results: $results, status: $status)';
  }
}

/// @nodoc
abstract mixin class _$TextSearchResponseDtoCopyWith<$Res>
    implements $TextSearchResponseDtoCopyWith<$Res> {
  factory _$TextSearchResponseDtoCopyWith(_TextSearchResponseDto value,
          $Res Function(_TextSearchResponseDto) _then) =
      __$TextSearchResponseDtoCopyWithImpl;
  @override
  @useResult
  $Res call({List<PlaceItemDto> results, String? status});
}

/// @nodoc
class __$TextSearchResponseDtoCopyWithImpl<$Res>
    implements _$TextSearchResponseDtoCopyWith<$Res> {
  __$TextSearchResponseDtoCopyWithImpl(this._self, this._then);

  final _TextSearchResponseDto _self;
  final $Res Function(_TextSearchResponseDto) _then;

  /// Create a copy of TextSearchResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? results = null,
    Object? status = freezed,
  }) {
    return _then(_TextSearchResponseDto(
      results: null == results
          ? _self._results
          : results // ignore: cast_nullable_to_non_nullable
              as List<PlaceItemDto>,
      status: freezed == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
mixin _$NearbySearchResponseDto {
  List<PlaceItemDto> get results;
  String? get status;

  /// Create a copy of NearbySearchResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $NearbySearchResponseDtoCopyWith<NearbySearchResponseDto> get copyWith =>
      _$NearbySearchResponseDtoCopyWithImpl<NearbySearchResponseDto>(
          this as NearbySearchResponseDto, _$identity);

  /// Serializes this NearbySearchResponseDto to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is NearbySearchResponseDto &&
            const DeepCollectionEquality().equals(other.results, results) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(results), status);

  @override
  String toString() {
    return 'NearbySearchResponseDto(results: $results, status: $status)';
  }
}

/// @nodoc
abstract mixin class $NearbySearchResponseDtoCopyWith<$Res> {
  factory $NearbySearchResponseDtoCopyWith(NearbySearchResponseDto value,
          $Res Function(NearbySearchResponseDto) _then) =
      _$NearbySearchResponseDtoCopyWithImpl;
  @useResult
  $Res call({List<PlaceItemDto> results, String? status});
}

/// @nodoc
class _$NearbySearchResponseDtoCopyWithImpl<$Res>
    implements $NearbySearchResponseDtoCopyWith<$Res> {
  _$NearbySearchResponseDtoCopyWithImpl(this._self, this._then);

  final NearbySearchResponseDto _self;
  final $Res Function(NearbySearchResponseDto) _then;

  /// Create a copy of NearbySearchResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? results = null,
    Object? status = freezed,
  }) {
    return _then(_self.copyWith(
      results: null == results
          ? _self.results
          : results // ignore: cast_nullable_to_non_nullable
              as List<PlaceItemDto>,
      status: freezed == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [NearbySearchResponseDto].
extension NearbySearchResponseDtoPatterns on NearbySearchResponseDto {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_NearbySearchResponseDto value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _NearbySearchResponseDto() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_NearbySearchResponseDto value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _NearbySearchResponseDto():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_NearbySearchResponseDto value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _NearbySearchResponseDto() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(List<PlaceItemDto> results, String? status)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _NearbySearchResponseDto() when $default != null:
        return $default(_that.results, _that.status);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(List<PlaceItemDto> results, String? status) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _NearbySearchResponseDto():
        return $default(_that.results, _that.status);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(List<PlaceItemDto> results, String? status)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _NearbySearchResponseDto() when $default != null:
        return $default(_that.results, _that.status);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _NearbySearchResponseDto implements NearbySearchResponseDto {
  const _NearbySearchResponseDto(
      {final List<PlaceItemDto> results = const <PlaceItemDto>[], this.status})
      : _results = results;
  factory _NearbySearchResponseDto.fromJson(Map<String, dynamic> json) =>
      _$NearbySearchResponseDtoFromJson(json);

  final List<PlaceItemDto> _results;
  @override
  @JsonKey()
  List<PlaceItemDto> get results {
    if (_results is EqualUnmodifiableListView) return _results;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_results);
  }

  @override
  final String? status;

  /// Create a copy of NearbySearchResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$NearbySearchResponseDtoCopyWith<_NearbySearchResponseDto> get copyWith =>
      __$NearbySearchResponseDtoCopyWithImpl<_NearbySearchResponseDto>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$NearbySearchResponseDtoToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _NearbySearchResponseDto &&
            const DeepCollectionEquality().equals(other._results, _results) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_results), status);

  @override
  String toString() {
    return 'NearbySearchResponseDto(results: $results, status: $status)';
  }
}

/// @nodoc
abstract mixin class _$NearbySearchResponseDtoCopyWith<$Res>
    implements $NearbySearchResponseDtoCopyWith<$Res> {
  factory _$NearbySearchResponseDtoCopyWith(_NearbySearchResponseDto value,
          $Res Function(_NearbySearchResponseDto) _then) =
      __$NearbySearchResponseDtoCopyWithImpl;
  @override
  @useResult
  $Res call({List<PlaceItemDto> results, String? status});
}

/// @nodoc
class __$NearbySearchResponseDtoCopyWithImpl<$Res>
    implements _$NearbySearchResponseDtoCopyWith<$Res> {
  __$NearbySearchResponseDtoCopyWithImpl(this._self, this._then);

  final _NearbySearchResponseDto _self;
  final $Res Function(_NearbySearchResponseDto) _then;

  /// Create a copy of NearbySearchResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? results = null,
    Object? status = freezed,
  }) {
    return _then(_NearbySearchResponseDto(
      results: null == results
          ? _self._results
          : results // ignore: cast_nullable_to_non_nullable
              as List<PlaceItemDto>,
      status: freezed == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
mixin _$DetailsResponseDto {
  PlaceDetailsDto? get result;
  String? get status;

  /// Create a copy of DetailsResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DetailsResponseDtoCopyWith<DetailsResponseDto> get copyWith =>
      _$DetailsResponseDtoCopyWithImpl<DetailsResponseDto>(
          this as DetailsResponseDto, _$identity);

  /// Serializes this DetailsResponseDto to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DetailsResponseDto &&
            (identical(other.result, result) || other.result == result) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, result, status);

  @override
  String toString() {
    return 'DetailsResponseDto(result: $result, status: $status)';
  }
}

/// @nodoc
abstract mixin class $DetailsResponseDtoCopyWith<$Res> {
  factory $DetailsResponseDtoCopyWith(
          DetailsResponseDto value, $Res Function(DetailsResponseDto) _then) =
      _$DetailsResponseDtoCopyWithImpl;
  @useResult
  $Res call({PlaceDetailsDto? result, String? status});

  $PlaceDetailsDtoCopyWith<$Res>? get result;
}

/// @nodoc
class _$DetailsResponseDtoCopyWithImpl<$Res>
    implements $DetailsResponseDtoCopyWith<$Res> {
  _$DetailsResponseDtoCopyWithImpl(this._self, this._then);

  final DetailsResponseDto _self;
  final $Res Function(DetailsResponseDto) _then;

  /// Create a copy of DetailsResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? result = freezed,
    Object? status = freezed,
  }) {
    return _then(_self.copyWith(
      result: freezed == result
          ? _self.result
          : result // ignore: cast_nullable_to_non_nullable
              as PlaceDetailsDto?,
      status: freezed == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }

  /// Create a copy of DetailsResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PlaceDetailsDtoCopyWith<$Res>? get result {
    if (_self.result == null) {
      return null;
    }

    return $PlaceDetailsDtoCopyWith<$Res>(_self.result!, (value) {
      return _then(_self.copyWith(result: value));
    });
  }
}

/// Adds pattern-matching-related methods to [DetailsResponseDto].
extension DetailsResponseDtoPatterns on DetailsResponseDto {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_DetailsResponseDto value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DetailsResponseDto() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_DetailsResponseDto value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DetailsResponseDto():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_DetailsResponseDto value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DetailsResponseDto() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(PlaceDetailsDto? result, String? status)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DetailsResponseDto() when $default != null:
        return $default(_that.result, _that.status);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(PlaceDetailsDto? result, String? status) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DetailsResponseDto():
        return $default(_that.result, _that.status);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(PlaceDetailsDto? result, String? status)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DetailsResponseDto() when $default != null:
        return $default(_that.result, _that.status);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _DetailsResponseDto implements DetailsResponseDto {
  const _DetailsResponseDto({this.result, this.status});
  factory _DetailsResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DetailsResponseDtoFromJson(json);

  @override
  final PlaceDetailsDto? result;
  @override
  final String? status;

  /// Create a copy of DetailsResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DetailsResponseDtoCopyWith<_DetailsResponseDto> get copyWith =>
      __$DetailsResponseDtoCopyWithImpl<_DetailsResponseDto>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$DetailsResponseDtoToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _DetailsResponseDto &&
            (identical(other.result, result) || other.result == result) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, result, status);

  @override
  String toString() {
    return 'DetailsResponseDto(result: $result, status: $status)';
  }
}

/// @nodoc
abstract mixin class _$DetailsResponseDtoCopyWith<$Res>
    implements $DetailsResponseDtoCopyWith<$Res> {
  factory _$DetailsResponseDtoCopyWith(
          _DetailsResponseDto value, $Res Function(_DetailsResponseDto) _then) =
      __$DetailsResponseDtoCopyWithImpl;
  @override
  @useResult
  $Res call({PlaceDetailsDto? result, String? status});

  @override
  $PlaceDetailsDtoCopyWith<$Res>? get result;
}

/// @nodoc
class __$DetailsResponseDtoCopyWithImpl<$Res>
    implements _$DetailsResponseDtoCopyWith<$Res> {
  __$DetailsResponseDtoCopyWithImpl(this._self, this._then);

  final _DetailsResponseDto _self;
  final $Res Function(_DetailsResponseDto) _then;

  /// Create a copy of DetailsResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? result = freezed,
    Object? status = freezed,
  }) {
    return _then(_DetailsResponseDto(
      result: freezed == result
          ? _self.result
          : result // ignore: cast_nullable_to_non_nullable
              as PlaceDetailsDto?,
      status: freezed == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }

  /// Create a copy of DetailsResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PlaceDetailsDtoCopyWith<$Res>? get result {
    if (_self.result == null) {
      return null;
    }

    return $PlaceDetailsDtoCopyWith<$Res>(_self.result!, (value) {
      return _then(_self.copyWith(result: value));
    });
  }
}

// dart format on
