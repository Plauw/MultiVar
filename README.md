# MultiVar
An easy to use Swift class that deals with multiple value markers.

Example of usage:
var mvar = MultiVar( withReferenceValue: 123, andValues: [0,10,123,124,125] )

if let refVal = mvar.referenceValue {

    print(refVal)
}

print(mvar.addCount)
print(mvar.average)
print(mvar.description)

if let placeHolderStr = mvar.placeholderString {
    print(placeHolderStr)
}

print(mvar.statsString)
