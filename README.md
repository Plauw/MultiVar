# MultiVar
An easy to use Swift class that deals with multiple value markers.

## Abstract
In an user interface it's quite common to deal with a selection of multiple values. For example, when a user selected more that one row in a list of values that he would like to edit. With one edit field, the user normaly sees a multiple value marker string like: 'Multiple values selected'.

This class will help the programmer to provide more information about the selection of values.

## Example of usage:

```swift
var mvar = MultiVar( withReferenceValue: 123, andValues: [0, 10, 10 ,123,124,125, 123] )

print( "reference value:", mvar.referenceValue! )
print( "values added:", mvar.addCount)
print( "lowest value:", mvar.lowest!)
print( "highest value:", mvar.highest!)
print( "average:", mvar.average)
print( "placeholder string: '", mvar.placeholderString!, "'")
print( "Stats string:\n'", mvar.statsString, "'")
```
### Output
---
reference value: 123 <br/>
values added: 7 <br/>
lowest value: 0 <br/>
highest value: 125 <br/>
average: 73.5714285714286 <br/>
placeholder string: ' Multiple values: 0, 10, 123..125 ' <br/>
Stats string:  <br/>
' Statistics <br/>
 <br/>
Sum is 515. <br/>
Total entries is 7 of which 5 unique. <br/>
Average: 73.57 <br/>
Range: 0 ≤ i ≤ 125. ' <br/>
